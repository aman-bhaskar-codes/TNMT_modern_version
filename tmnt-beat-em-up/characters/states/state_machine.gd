class_name StateMachine
extends RefCounted

signal state_changed(from_name: String, to_name: String)

var _states: Dictionary = {}
var _current
var _previous

func add_state(state) -> void:
	_states[state.state_name] = state

func initialize(starting) -> void:
	_current = starting
	_current.enter()

func transition_to(name: String) -> void:
	assert(_states.has(name), "Unknown state")

	var next = _states[name]
	if next == _current:
		return

	_previous = _current
	_current.exit()
	_current = next
	_current.enter()

	state_changed.emit(_previous.state_name, _current.state_name)

func update(delta: float) -> void:
	_current.update(delta)

func physics_update(delta: float) -> void:
	_current.physics_update(delta)

func current_name() -> String:
	return _current.state_name