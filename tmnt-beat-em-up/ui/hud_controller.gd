class_name HUDController
extends Control

@onready var hp_bar: ProgressBar = %HPBar
@onready var hp_label: Label = %HPLabel
@onready var lives_label: Label = %LivesLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_counter: Label = %ComboCounter
@onready var combo_panel: Panel = %ComboPanel

var _combo_hide_timer: float = 0.0

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	combo_panel.visible = false

func init_player(player: PlayerController) -> void:
	player.health_changed.connect(_on_health_changed)
	player.combo.combo_hit.connect(_on_combo_hit)
	player.combo.combo_break.connect(_on_combo_break)
	player.combo.combo_complete.connect(_on_combo_complete)

	hp_bar.max_value = player.stats.max_health
	hp_bar.value = player.current_health

	hp_label.text = "%d / %d" % [player.current_health, player.stats.max_health]
	lives_label.text = "x%d" % GameManager.lives

func _process(delta: float) -> void:
	if combo_panel.visible:
		_combo_hide_timer -= delta
		if _combo_hide_timer <= 0.0:
			combo_panel.visible = false

# ---------- SIGNALS ----------

func _on_health_changed(cur: int, mx: int) -> void:
	hp_bar.value = cur
	hp_label.text = "%d / %d" % [cur, mx]

	var tw := create_tween()
	tw.tween_property(hp_bar, "modulate", Color("F87171"), 0.08)
	tw.tween_property(hp_bar, "modulate", Color.WHITE, 0.25)

func _on_score_changed(total: int) -> void:
	score_label.text = "%08d" % total

func _on_lives_changed(remaining: int) -> void:
	lives_label.text = "x%d" % remaining

func _on_combo_hit(hit_index: int, _mult: float) -> void:
	combo_panel.visible = true
	_combo_hide_timer = 1.8
	combo_counter.text = "%d HIT" % (hit_index + 1)

	var tw := create_tween()
	tw.tween_property(combo_counter, "scale", Vector2(1.3, 1.3), 0.06)
	tw.tween_property(combo_counter, "scale", Vector2(1.0, 1.0), 0.12)

func _on_combo_break() -> void:
	combo_panel.visible = false

func _on_combo_complete(total: int, _bonus: int) -> void:
	combo_counter.text = "COMBO x%d!" % total
	_combo_hide_timer = 2.0