class_name PlayerState
extends RefCounted

var state_name: String = "Base"
var player
var fsm

func _init(p, f) -> void:
	player = p
	fsm = f

func enter() -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
func physics_update(_delta: float) -> void: pass

func _check_jump() -> bool:
	if player.jump_buffered and (player.is_on_floor() or player.coyote_timer > 0.0):
		fsm.transition_to("Jump")
		return true
	return false

func _resolve_ground_state() -> void:
	if InputReader.move_direction.x != 0.0:
		fsm.transition_to("Run")
	else:
		fsm.transition_to("Idle")