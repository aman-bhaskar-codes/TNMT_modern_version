extends Node2D

@onready var player: PlayerController = $PlayerController
@onready var hud: HUDController = $UI/HUDController
@onready var cam: CameraController = $Camera2D

func _ready() -> void:
	# Register player
	GameManager.register_player(player)

	# HUD setup
	hud.init_player(player)

	# Camera follow
	cam.target = player

	# Spawn enemies
	_spawn_enemy(Vector2(320, 180))
	_spawn_enemy(Vector2(640, 180))

	print("Level ready")

func _spawn_enemy(pos: Vector2) -> void:
	var enemy_scene := preload("res://characters/enemies/foot_soldier.tscn")
	var e = enemy_scene.instantiate()
	e.global_position = pos
	add_child(e)