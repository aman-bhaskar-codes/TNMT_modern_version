class_name HitState
extends PlayerState

const STUN_DURATION := 0.35
const IFRAMES_EXTRA := 0.90

var _stun_timer: float = 0.0

func _init(p, f) -> void:
	super(p, f)
	state_name = "Hit"

func enter() -> void:
	_stun_timer = STUN_DURATION
	player.is_invincible = true
	player.combo.reset()

	player.play_anim("hit")

	var tw := player.create_tween().set_loops(
		int((STUN_DURATION + IFRAMES_EXTRA) / 0.10)
	)

	tw.tween_property(player.sprite, "modulate:a", 0.15, 0.05)
	tw.tween_property(player.sprite, "modulate:a", 1.0, 0.05)

	player.get_tree().create_timer(
		STUN_DURATION + IFRAMES_EXTRA
	).timeout.connect(_clear_iframes)

func update(delta: float) -> void:
	_stun_timer -= delta

	if _stun_timer <= 0.0:
		if player.current_health <= 0:
			fsm.transition_to("Dead")
		else:
			fsm.transition_to("Idle")

func physics_update(delta: float) -> void:
	player.apply_friction(delta)
	player.apply_gravity(delta)
	player.move_and_slide()

func _clear_iframes() -> void:
	player.is_invincible = false
	player.sprite.modulate.a = 1.0