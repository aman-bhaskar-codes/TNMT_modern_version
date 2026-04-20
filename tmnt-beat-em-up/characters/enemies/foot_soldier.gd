class_name FootSoldier
extends CharacterBody2D

# ---------- CONFIG ----------
@export var move_speed: float = 90.0
@export var attack_range: float = 52.0
@export var chase_range: float = 280.0
@export var max_health: int = 60
@export var attack_damage: float = 15.0
@export var score_value: int = 100

# ---------- CHILD NODES ----------
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: HurtBox = $HurtBox
@onready var hitbox: HitBox = $HitBox

# ---------- STATE ----------
var current_health: int = 60
var _player: PlayerController
var _state: String = "idle"
var _state_timer: float = 0.0

const GRAVITY := 900.0

# ---------- READY ----------
func _ready() -> void:
	current_health = max_health

	hurtbox.owner_faction = "enemy"
	hitbox.owner_faction = "enemy"

	hurtbox.hurt.connect(_on_hurt)
	hitbox.hit_connected.connect(func(t, d): print("[Enemy hit player]: ", d))

	_find_player()

# ---------- FIND PLAYER ----------
func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as PlayerController

# ---------- PHYSICS ----------
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_run_fsm(delta)
	move_and_slide()

# ---------- GRAVITY ----------
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

# ---------- FSM ----------
func _run_fsm(delta: float) -> void:
	_state_timer += delta

	if not _player:
		_find_player()
		return

	var dist := global_position.distance_to(_player.global_position)

	match _state:

		"idle":
			anim.play("idle")
			velocity.x = 0.0

			if dist < chase_range:
				_change_state("chase")

		"chase":
			anim.play("run")

			var dir := sign(_player.global_position.x - global_position.x)
			velocity.x = dir * move_speed
			sprite.scale.x = dir

			if dist <= attack_range:
				_change_state("attack")
			elif dist > chase_range:
				_change_state("idle")

		"attack":
			velocity.x = 0.0

			if _state_timer < 0.12:
				anim.play("attack_windup")

			elif _state_timer < 0.30:
				anim.play("attack_active")

				hitbox.show_hitbox(
					attack_damage,
					Vector2(sign(_player.global_position.x - global_position.x) * 120.0, -60.0)
				)

			else:
				hitbox.hide_hitbox()

			if _state_timer > 0.55:
				_change_state("idle")

		"stun":
			anim.play("hit")
			velocity.x = lerp(velocity.x, 0.0, 0.15)

			if _state_timer > 0.40:
				_change_state("idle")

		"dead":
			velocity.x = lerp(velocity.x, 0.0, 0.18)

# ---------- STATE CHANGE ----------
func _change_state(new_state: String) -> void:
	hitbox.hide_hitbox()
	_state = new_state
	_state_timer = 0.0

# ---------- DAMAGE ----------
func _on_hurt(damage: float, knockback: Vector2, _pause: int, _launch: bool) -> void:
	if _state == "dead":
		return

	current_health -= int(damage)
	velocity += knockback

	if current_health <= 0:
		_die()
	else:
		_change_state("stun")

	if DamageNumbers:
		DamageNumbers.spawn(global_position - Vector2(0, 30), damage)

	if HitParticlesManager:
		HitParticlesManager.spawn(global_position, HitParticles.HitType.LIGHT, 1.0)

# ---------- DEATH ----------
func _die() -> void:
	_change_state("dead")
	anim.play("dead")

	if GameManager:
		GameManager.add_score(score_value)

	await get_tree().create_timer(1.2).timeout
	queue_free()