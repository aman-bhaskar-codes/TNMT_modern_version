class_name DamageNumber
extends Label

const FLOAT_HEIGHT := -52.0
const FLOAT_TIME := 0.65
const FADE_START := 0.35

var _tween: Tween

func _ready() -> void:
	z_index = 100
	add_theme_font_size_override("font_size", 18)

func show_damage(amount: float, pos: Vector2, is_critical: bool = false) -> void:
	global_position = pos + Vector2(randf_range(-12.0, 12.0), -20.0)

	var display := int(amount)

	if is_critical:
		text = "!" + str(display) + "!"
		add_theme_color_override("font_color", Color("FBBF24"))
		add_theme_font_size_override("font_size", 24)
	else:
		text = str(display)
		add_theme_color_override("font_color", Color("FFFFFF"))
		add_theme_font_size_override("font_size", 18)

	modulate.a = 1.0
	visible = true

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)

	_tween.tween_property(self, "position:y",
		position.y + FLOAT_HEIGHT, FLOAT_TIME
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "modulate:a",
		0.0, FADE_START
	).set_delay(FLOAT_TIME - FADE_START)

	_tween.chain().tween_callback(func(): visible = false)