class_name HurtBox
extends Area2D

@export var owner_faction: String = "player"

signal hurt(damage: float, knockback: Vector2, hit_pause_ms: int, launch_up: bool)

func _ready() -> void:
	monitoring = true
	monitorable = true

func receive_hit(damage: float, knockback: Vector2, hit_pause_ms: int, launch_up: bool) -> void:
	hurt.emit(damage, knockback, hit_pause_ms, launch_up)