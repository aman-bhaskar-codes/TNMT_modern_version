extends Node

signal move_input_changed(direction: Vector2)
signal jump_pressed
signal jump_released
signal light_attack_pressed
signal heavy_attack_pressed
signal special_pressed
signal pause_toggled

var move_direction: Vector2 = Vector2.ZERO
var is_jump_held: bool = false

func _process(_delta: float) -> void:
	var raw := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if raw != move_direction:
		move_direction = raw
		move_input_changed.emit(move_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		is_jump_held = true
		jump_pressed.emit()

	if event.is_action_released("jump"):
		is_jump_held = false
		jump_released.emit()

	if event.is_action_pressed("light_attack"):
		light_attack_pressed.emit()

	if event.is_action_pressed("heavy_attack"):
		heavy_attack_pressed.emit()

	if event.is_action_pressed("special"):
		special_pressed.emit()

	if event.is_action_pressed("ui_cancel"):
		pause_toggled.emit()