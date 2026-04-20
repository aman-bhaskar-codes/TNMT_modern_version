class_name AerialAttackState
extends PlayerState

const DAMAGE := 24.0
const KNOCKBACK := Vector2(160.0, 80.0)

const ACTIVE_T := 0.20
const FULL_T := 0.32

const DIVE_MULT := 0.5

var _timer: float = 0.0
var _hitbox_open: bool = false
var _used: bool = false

func _init(p, f) -> void:
	super(p, f)
	state_name = "AerialAttack"

func enter() -> void:
	if _used:
		fsm.transition_to("Fall")
		return

	_used = true
	_timer = 0.0
	_hitbox_open = false

	player.velocity.x *= DIVE_MULT
	player.play_anim("attack_aerial")

func reset_aerial() -> void:
	_used = false

func exit() -> void:
	player.hitbox_light.hide_hitbox()

func physics_update(delta: float) -> void:
	_timer += delta

	if _timer < ACTIVE_T and not _hitbox_open:
		_hitbox_open = true
		player.hitbox_light.show_hitbox(DAMAGE, KNOCKBACK)

	if _hitbox_open and _timer >= ACTIVE_T:
		player.hitbox_light.hide_hitbox()
		_hitbox_open = false

	if _timer >= FULL_T or player.is_on_floor():
		fsm.transition_to("Idle")
		return

	player.apply_horizontal_movement(delta)
	player.apply_gravity(delta)
	player.move_and_slide()