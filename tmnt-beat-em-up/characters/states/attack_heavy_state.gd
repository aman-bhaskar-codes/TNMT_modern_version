class_name HeavyAttackState
extends PlayerState

const DAMAGE := 45.0
const KNOCKBACK := Vector2(380.0, -100.0)
const HIT_PAUSE := 80

const STARTUP_T := 0.14
const ACTIVE_T := 0.26
const RECOVER_T := 0.38

var _timer: float = 0.0
var _hitbox_open: bool = false

func _init(p, f) -> void:
	super(p, f)
	state_name = "HeavyAttack"

func enter() -> void:
	_timer = 0.0
	_hitbox_open = false
	player.velocity.x *= 0.1
	player.play_anim("attack_heavy")
	player.combo.reset()

func exit() -> void:
	player.hitbox_heavy.hide_hitbox()

func physics_update(delta: float) -> void:
	_timer += delta

	if _timer < STARTUP_T:
		player.apply_gravity(delta)
		player.move_and_slide()
		return

	if _timer < STARTUP_T + ACTIVE_T:
		if not _hitbox_open:
			_hitbox_open = true
			player.hitbox_heavy.show_hitbox(DAMAGE, KNOCKBACK)

		player.apply_gravity(delta)
		player.move_and_slide()
		return

	player.hitbox_heavy.hide_hitbox()

	if _timer >= RECOVER_T:
		fsm.transition_to("Idle")

	player.apply_gravity(delta)
	player.move_and_slide()