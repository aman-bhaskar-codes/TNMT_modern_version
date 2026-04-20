class_name RunState
extends PlayerState

func _init(p, f) -> void:
	super(p, f)
	state_name = "Run"

func enter() -> void:
	player.play_anim("run")

func update(_delta: float) -> void:
	if InputReader.move_direction.x == 0.0:
		fsm.transition_to("Idle")
		return

	_check_jump()

func physics_update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.apply_gravity(delta)
	player.move_and_slide()