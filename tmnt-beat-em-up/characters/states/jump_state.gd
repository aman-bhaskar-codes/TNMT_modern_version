class_name JumpState
extends PlayerState

func _init(p, f) -> void:
	super(p, f)
	state_name = "Jump"

func enter() -> void:
	player.execute_jump()
	player.play_anim("jump")

func update(_delta: float) -> void:
	if player.velocity.y >= 0.0:
		fsm.transition_to("Fall")

func physics_update(delta: float) -> void:
	player.apply_horizontal_movement(delta)
	player.apply_gravity(delta)
	player.move_and_slide()