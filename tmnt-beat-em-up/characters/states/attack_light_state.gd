class_name LightAttackState
extends PlayerState

const ANIM_NAMES := ["attack_light_1", "attack_light_2", "attack_light_3"]

const HITBOX_WINDOWS := [
	[0.05, 0.18],
	[0.05, 0.18],
	[0.08, 0.28],
]

const DAMAGE := [18.0, 18.0, 28.0]

const KNOCKBACK := [
	Vector2(140.0, -30.0),
	Vector2(160.0, -40.0),
	Vector2(120.0, -280.0),
]

var _hit_index: int = 0
var _anim_timer: float = 0.0
var _anim_duration: float = 0.28
var _hitbox_open: bool = false
var _can_chain: bool = false
var _chain_pressed: bool = false

func _init(p, f) -> void:
	super(p, f)
	state_name = "LightAttack"

func enter() -> void:
	_hit_index = player.combo.current_hit
	_chain_pressed = false
	_can_chain = false
	_anim_timer = 0.0

	var anim_name := ANIM_NAMES[min(_hit_index, 2)]
	player.play_anim(anim_name)

	player.velocity.x *= 0.25

	InputReader.light_attack_pressed.connect(_on_chain_input)

func exit() -> void:
	_close_hitbox()
	InputReader.light_attack_pressed.disconnect(_on_chain_input)

func physics_update(delta: float) -> void:
	_anim_timer += delta

	var w := HITBOX_WINDOWS[min(_hit_index, 2)]

	if not _hitbox_open and _anim_timer >= w[0]:
		_open_hitbox(_hit_index)

	if _hitbox_open and _anim_timer >= w[1]:
		_close_hitbox()
		_can_chain = true

	if _anim_timer >= _anim_duration:
		if _chain_pressed and _can_chain and player.combo.can_extend():
			player.combo.register_hit()
			fsm.transition_to("LightAttack")
		else:
			player.combo.reset()
			_resolve()

	player.apply_gravity(delta)
	player.move_and_slide()

func _open_hitbox(idx: int) -> void:
	_hitbox_open = true
	player.hitbox_light.show_hitbox(DAMAGE[idx], KNOCKBACK[idx])

func _close_hitbox() -> void:
	_hitbox_open = false
	player.hitbox_light.hide_hitbox()

func _on_chain_input() -> void:
	_chain_pressed = true

func _resolve() -> void:
	if player.is_on_floor():
		fsm.transition_to("Idle")
	else:
		fsm.transition_to("Fall")