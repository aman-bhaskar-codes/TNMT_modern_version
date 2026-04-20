class_name FallState
extends PlayerState

func _init(p, f) -> void:
	super(p, f)
	state_name = "Fall"

func enter() -> void:
	player.play_anim("fall")

func update(_delta: float) -> void:
	if player.is_on_floor():
		_resolve_ground_state()

func physics_update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.apply_gravity(delta)
	player.move_and_slide()