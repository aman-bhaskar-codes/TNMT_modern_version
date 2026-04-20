class_name PlayerController
extends CharacterBody2D

@export var stats

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

var fsm

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var jump_buffered: bool = false

var current_health: int = 100
var is_invincible: bool = false

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
	current_health = stats.max_health
	_build_fsm()
	_wire_input()

func _build_fsm() -> void:
	fsm = StateMachine.new()

	var states = [
		IdleState.new(self, fsm),
		RunState.new(self, fsm),
		JumpState.new(self, fsm),
		FallState.new(self, fsm),
	]

	for s in states:
		fsm.add_state(s)

	fsm.initialize(fsm._states["Idle"])

func _wire_input() -> void:
	InputReader.jump_pressed.connect(_on_jump_pressed)
	InputReader.jump_released.connect(_on_jump_released)

func _process(delta: float) -> void:
	_tick_coyote(delta)
	_tick_jump_buffer(delta)
	fsm.update(delta)
	_sync_facing()

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
	_apply_lane_depth()

func apply_horizontal_movement(delta: float) -> void:
	var target := InputReader.move_direction.x * stats.move_speed
	velocity.x = lerp(velocity.x, target, stats.acceleration * delta * 60.0)

func apply_friction(delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, stats.deceleration * delta * 60.0)

func apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		return

	var g := stats.gravity
	if velocity.y > 0.0:
		g *= stats.fall_gravity_multiplier

	velocity.y = minf(velocity.y + g * delta, stats.max_fall_speed)

func execute_jump() -> void:
	velocity.y = stats.jump_velocity
	jump_buffered = false
	jump_buffer_timer = 0.0
	coyote_timer = 0.0

func _apply_lane_depth() -> void:
	if not is_on_floor():
		return

	var lane := InputReader.move_direction.y
	if absf(lane) > 0.01:
		position.y += lane * stats.lane_speed

func _on_jump_pressed() -> void:
	jump_buffered = true
	jump_buffer_timer = stats.jump_buffer_time

func _on_jump_released() -> void:
	if velocity.y < 0.0:
		velocity.y *= stats.cut_jump_multiplier

func _tick_jump_buffer(delta: float) -> void:
	if not jump_buffered:
		return

	jump_buffer_timer -= delta
	if jump_buffer_timer <= 0.0:
		jump_buffered = false

func _tick_coyote(delta: float) -> void:
	if is_on_floor():
		coyote_timer = stats.coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

func _sync_facing() -> void:
	var x := InputReader.move_direction.x
	if x > 0.01:
		sprite.scale.x = 1.0
	elif x < -0.01:
		sprite.scale.x = -1.0

func play_anim(anim_name: String) -> void:
	if anim.current_animation != anim_name:
		anim.play(anim_name)