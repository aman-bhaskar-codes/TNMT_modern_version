class_name PlayerStats
extends Resource

@export_group("Identity")
@export var character_name: String = "Leonardo"
@export var accent_color: Color = Color("22D3EE")
@export var portrait: Texture2D

@export_group("Movement")
@export_range(200.0, 800.0, 10.0) var move_speed: float = 380.0
@export_range(0.05, 1.0, 0.01) var acceleration: float = 0.22
@export_range(0.05, 1.0, 0.01) var deceleration: float = 0.14
@export_range(2.0, 8.0, 0.5) var lane_speed: float = 3.5

@export_group("Jump")
@export_range(-1200.0, -200.0, 10.0) var jump_velocity: float = -520.0
@export_range(0.0, 1.0) var cut_jump_multiplier: float = 0.45
@export_range(0.05, 0.35) var coyote_time: float = 0.14
@export_range(0.05, 0.35) var jump_buffer_time: float = 0.12

@export_group("Physics")
@export_range(600.0, 2500.0) var gravity: float = 1400.0
@export_range(1.0, 4.0) var fall_gravity_multiplier: float = 1.75
@export_range(400.0, 2000.0) var max_fall_speed: float = 1200.0

@export_group("Combat — Phase 2")
@export_range(5.0, 100.0) var attack_damage: float = 20.0
@export_range(0.1, 1.5) var attack_cooldown: float = 0.35
@export_range(0.05, 0.4) var combo_window: float = 0.22

@export_group("Health")
@export_range(50, 300) var max_health: int = 100
@export var max_lives: int = 3
@export_range(0.5, 3.0) var invincibility_frames: float = 1.2