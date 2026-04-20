class_name HitParticles
extends Node

enum HitType { LIGHT, HEAVY, SPECIAL, DEATH }

@export var pool_size: int = 12

var _pool: Array[GPUParticles2D] = []
var _pool_idx: int = 0

func _ready() -> void:
	_build_pool()

func _build_pool() -> void:
	for i in range(pool_size):
		var p := GPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 0.95
		p.process_material = _make_material()
		add_child(p)
		_pool.append(p)

func spawn(pos: Vector2, hit_type: HitType = HitType.LIGHT, facing: float = 1.0) -> void:
	var p := _pool[_pool_idx % pool_size]
	_pool_idx += 1

	p.global_position = pos
	p.emitting = false

	match hit_type:
		HitType.LIGHT:
			p.amount = 8
			p.lifetime = 0.28
			_set_color(p, Color("FBBF24"))

		HitType.HEAVY:
			p.amount = 16
			p.lifetime = 0.40
			_set_color(p, Color("F87171"))

		HitType.SPECIAL:
			p.amount = 24
			p.lifetime = 0.55
			_set_color(p, Color("22D3EE"))

		HitType.DEATH:
			p.amount = 32
			p.lifetime = 0.80
			_set_color(p, Color("FFFFFF"))

	var mat := p.process_material as ParticleProcessMaterial
	if mat:
		mat.initial_velocity_min = 60.0 * facing
		mat.initial_velocity_max = 180.0

	p.emitting = true

func _make_material() -> ParticleProcessMaterial:
	var m := ParticleProcessMaterial.new()
	m.direction = Vector3(1, -1, 0)
	m.spread = 60.0
	m.initial_velocity_min = 80.0
	m.initial_velocity_max = 200.0
	m.gravity = Vector3(0, 300, 0)
	m.scale_min = 2.0
	m.scale_max = 5.0
	return m

func _set_color(p: GPUParticles2D, c: Color) -> void:
	var g := Gradient.new()
	g.set_color(0, c)
	g.set_color(1, Color(c, 0.0))

	var gt := GradientTexture1D.new()
	gt.gradient = g

	(p.process_material as ParticleProcessMaterial).color_ramp = gt