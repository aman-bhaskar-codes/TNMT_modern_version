class_name HitBox
extends Area2D

@export var damage: float = 20.0
@export var knockback: Vector2 = Vector2(180.0, -80.0)
@export var hit_pause_ms: int = 60
@export var launch_up: bool = false

var owner_faction: String = "player"
var _active: bool = false

signal hit_connected(target: Node, damage: float)

func _ready() -> void:
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)
	collision_layer = 0

func show_hitbox(dmg: float = -1.0, kb: Vector2 = Vector2.ZERO) -> void:
	if dmg > 0.0:
		damage = dmg
	if kb != Vector2.ZERO:
		knockback = kb

	monitoring = true
	monitorable = true
	_active = true

func hide_hitbox() -> void:
	monitoring = false
	monitorable = false
	_active = false

func _on_area_entered(area: Area2D) -> void:
	if not _active:
		return

	if not area is HurtBox:
		return

	var hb := area as HurtBox

	if hb.owner_faction == owner_faction:
		return

	var kb := knockback
	if get_parent() and get_parent().has_method("get_facing"):
		kb.x *= get_parent().get_facing()

	hb.receive_hit(damage, kb, hit_pause_ms, launch_up)
	hit_connected.emit(hb.get_parent(), damage)

	hide_hitbox()