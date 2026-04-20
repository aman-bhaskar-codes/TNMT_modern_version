class_name IdleState
extends PlayerState

func _init(p, f) -> void:
	super(p, f)
	state_name = "Idle"

func enter() -> void:
	player.play_anim("idle")

func update(_delta: float) -> void:
	if InputReader.move_direction.x != 0.0:
		fsm.transition_to("Run")
		return

	_check_jump()

func physics_update(delta: float) -> void:
	player.apply_friction(delta)
	player.apply_gravity(delta)
	player.move_and_slide()