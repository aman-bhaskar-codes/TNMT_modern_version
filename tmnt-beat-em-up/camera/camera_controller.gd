class_name CameraController
extends Camera2D

@export var target: CharacterBody2D
@export var follow_speed: float = 7.0
@export var look_ahead_dist: float = 90.0
@export var look_ahead_speed: float = 5.5
@export var deadzone_x: float = 20.0

@export_group("Level Bounds")
@export var bounds_min: Vector2 = Vector2(-960, -400)
@export var bounds_max: Vector2 = Vector2(9600, 300)

var _look_offset: float = 0.0

func _ready() -> void:
	if target:
		global_position = target.global_position
		make_current()

func _process(delta: float) -> void:
	if not target:
		return

	var move_dir := sign(target.velocity.x)

	_look_offset = lerp(
		_look_offset,
		move_dir * look_ahead_dist,
		look_ahead_speed * delta
	)

	var vp := get_viewport_rect().size * 0.5

	var desired := Vector2(
		clampf(target.global_position.x + _look_offset,
			bounds_min.x + vp.x, bounds_max.x - vp.x),
		clampf(target.global_position.y,
			bounds_min.y + vp.y, bounds_max.y - vp.y)
	)

	global_position = global_position.lerp(desired, follow_speed * delta)