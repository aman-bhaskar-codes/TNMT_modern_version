class_name PlayerController
extends CharacterBody2D

@export var stats: PlayerStats

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var hitbox_light: HitBox = $HitBoxLight
@onready var hitbox_heavy: HitBox = $HitBoxHeavy
@onready var hurtbox: HurtBox = $HurtBox
@onready var combo: ComboController = $ComboController

var fsm: StateMachine

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_buffered: bool = false

var current_health: int = 100
var is_invincible: bool = false

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
    add_to_group("player")
	
	current_health = stats.max_health

	_build_fsm()
	_wire_input()

	hurtbox.hurt.connect(_on_hurt)

	hitbox_light.owner_faction = "player"
	hitbox_heavy.owner_faction = "player"

	hitbox_light.hit_connected.connect(_on_hit_connected)
	hitbox_heavy.hit_connected.connect(_on_hit_connected)

func _build_fsm() -> void:
	fsm = StateMachine.new()

	var states = [
		IdleState.new(self, fsm),
		RunState.new(self, fsm),
		JumpState.new(self, fsm),
		FallState.new(self, fsm),
		LightAttackState.new(self, fsm),
		HeavyAttackState.new(self, fsm),
		AerialAttackState.new(self, fsm),
		HitState.new(self, fsm),
		DeadState.new(self, fsm),
	]

	for s in states:
		fsm.add_state(s)

	fsm.initialize(states[0])

func _wire_input() -> void:
	InputReader.jump_pressed.connect(_on_jump_pressed)
	InputReader.jump_released.connect(_on_jump_released)
	InputReader.light_attack_pressed.connect(_on_light_attack)
	InputReader.heavy_attack_pressed.connect(_on_heavy_attack)

func _process(delta: float) -> void:
	_tick_coyote(delta)
	_tick_jump_buffer(delta)
	fsm.update(delta)

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)

# ---------- INPUT ----------

func _on_light_attack() -> void:
	var cs := fsm.current_name()

	if cs in ["Idle","Run"]:
		combo.register_hit()
		fsm.transition_to("LightAttack")
	elif cs in ["Jump","Fall"]:
		fsm.transition_to("AerialAttack")

func _on_heavy_attack() -> void:
	if fsm.current_name() in ["Idle","Run"]:
		fsm.transition_to("HeavyAttack")

# ---------- DAMAGE ----------

func _on_hurt(damage: float, knockback: Vector2, pause: int, _launch: bool) -> void:
	take_damage(int(damage), knockback, pause)

func take_damage(amount: int, knockback: Vector2, pause_ms: int) -> void:
	if is_invincible:
		return

	current_health -= amount
	velocity += knockback

	health_changed.emit(current_health, stats.max_health)

	if current_health <= 0:
		fsm.transition_to("Dead")
		died.emit()
	else:
		fsm.transition_to("Hit")

# ---------- HIT FX ----------

func _on_hit_connected(target: Node, damage: float) -> void:
	if DamageNumbers:
		DamageNumbers.spawn(target.global_position, damage)

# ---------- MOVEMENT ----------

func apply_horizontal_movement(delta: float) -> void:
	var dir := InputReader.move_direction.x
	if dir != 0.0:
		sprite.scale.x = sign(dir)
	velocity.x = lerp(velocity.x, dir * stats.move_speed, stats.acceleration)

func apply_friction(delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, stats.deceleration)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var grav_mult := stats.fall_gravity_multiplier if velocity.y > 0.0 else 1.0
		velocity.y += stats.gravity * grav_mult * delta
		velocity.y = minf(velocity.y, stats.max_fall_speed)

func execute_jump() -> void:
	velocity.y = stats.jump_velocity
	coyote_timer = 0.0
	jump_buffered = false
	jump_buffer_timer = 0.0

func get_facing() -> float:
	return sprite.scale.x

func play_anim(anim_name: String) -> void:
	if anim.has_animation(anim_name):
		anim.play(anim_name)

# ---------- TIMERS ----------

func _tick_coyote(delta: float) -> void:
	if is_on_floor():
		coyote_timer = stats.coyote_time
	else:
		coyote_timer -= delta

func _tick_jump_buffer(delta: float) -> void:
	if jump_buffered:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0.0:
			jump_buffered = false

func _on_jump_pressed() -> void:
	jump_buffered = true
	jump_buffer_timer = stats.jump_buffer_time

func _on_jump_released() -> void:
	if velocity.y < 0.0:
		velocity.y *= stats.cut_jump_multiplier