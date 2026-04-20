class_name ComboController
extends Node

@export var max_combo_hits: int = 3
@export var combo_window: float = 0.28
@export var damage_ramp: Array[float] = [1.0, 1.2, 1.6]

signal combo_hit(hit_index: int, damage_multiplier: float)
signal combo_break
signal combo_complete(total_hits: int, score_bonus: int)

var current_hit: int = 0
var combo_active: bool = false
var _window_timer: float = 0.0

func _process(delta: float) -> void:
	if not combo_active:
		return

	_window_timer -= delta
	if _window_timer <= 0.0:
		_break_combo()

func register_hit() -> float:
	combo_active = true
	_window_timer = combo_window

	var mult := damage_ramp[min(current_hit, damage_ramp.size() - 1)]
	combo_hit.emit(current_hit, mult)

	current_hit += 1

	if current_hit >= max_combo_hits:
		_finish_combo()

	return mult

func reset() -> void:
	current_hit = 0
	combo_active = false
	_window_timer = 0.0

func can_extend() -> bool:
	return combo_active and current_hit < max_combo_hits

func _break_combo() -> void:
	combo_break.emit()
	reset()

func _finish_combo() -> void:
	var bonus := current_hit * 50
	combo_complete.emit(current_hit, bonus)

	if GameManager:
		GameManager.add_score(bonus)

	reset()