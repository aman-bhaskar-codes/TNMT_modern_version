extends Node

signal lives_changed(remaining: int)
signal score_changed(total: int)
signal game_over
signal level_complete(next_level: int)

@export var starting_lives: int = 3
@export var points_per_enemy: int = 100

var lives: int = 3
var score: int = 0
var level: int = 1

var _player

func _ready() -> void:
	lives = starting_lives
	print("GameManager ready. Lives:", lives)

func register_player(player) -> void:
	_player = player
	player.died.connect(_on_player_died)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func complete_level() -> void:
	level += 1
	level_complete.emit(level)

	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/level_%02d.tscn" % level)

func _on_player_died() -> void:
	lives -= 1
	lives_changed.emit(lives)

	if lives <= 0:
		game_over.emit()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()