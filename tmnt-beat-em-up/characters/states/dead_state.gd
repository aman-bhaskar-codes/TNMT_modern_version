class_name DeadState
extends PlayerState

const DEATH_ANIM_LENGTH := 1.4

var _timer: float = 0.0

func _init(p, f) -> void:
	super(p, f)
	state_name = "Dead"

func enter() -> void:
	_timer = 0.0
	player.is_invincible = true
	player.velocity = Vector2.ZERO

	player.play_anim("dead")

	if player.has_node("DeathParticles"):
		player.get_node("DeathParticles").emitting = true

func update(delta: float) -> void:
	_timer += delta

	if _timer >= DEATH_ANIM_LENGTH:
		if GameManager:
			GameManager.player_died()

		player.set_process(false)
		player.set_physics_process(false)