class_name ScreenShake
extends Node

@onready var camera: Camera2D = get_parent()

var _trauma: float = 0.0
var _decay: float = 2.8
var _max_off: float = 14.0

const LIGHT_HIT := {trauma=0.25, decay=3.5}
const HEAVY_HIT := {trauma=0.75, decay=2.2}

func shake(trauma_add: float = 0.5, custom_decay: float = 0.0) -> void:
	_trauma = minf(_trauma + trauma_add, 1.0)
	if custom_decay > 0.0:
		_decay = custom_decay

func shake_profile(profile: Dictionary) -> void:
	shake(profile.trauma, profile.get("decay", _decay))

func _process(delta: float) -> void:
	if _trauma <= 0.0:
		camera.offset = Vector2.ZERO
		return

	_trauma = maxf(_trauma - _decay * delta, 0.0)

	var amount := _trauma * _trauma

	camera.offset = Vector2(
		randf_range(-1.0, 1.0) * _max_off * amount,
		randf_range(-1.0, 1.0) * _max_off * amount * 0.6
	)