extends Node

const POOL_SIZE := 20
const DamageNumberClass = preload("res://ui/damage_number.gd")

var _pool: Array = []
var _pool_idx: int = 0

func _ready() -> void:
	for i in range(POOL_SIZE):
		var d = DamageNumberClass.new()
		d.visible = false
		add_child(d)
		_pool.append(d)

func spawn(pos: Vector2, amount: float, critical: bool = false) -> void:
	var d := _pool[_pool_idx % POOL_SIZE]
	_pool_idx += 1

	d.show_damage(amount, pos, critical)