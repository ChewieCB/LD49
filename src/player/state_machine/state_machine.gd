extends Node
class_name StateMachine
# Generic State Machine, Initialises states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state

signal transitioned(state_path)

export var initial_state_path := NodePath()

onready var actor = get_parent()

onready var state = get_node(initial_state_path) setget set_state
onready var _state_name = state.name
var previous_state: State


func _init():
	add_to_group("state_machine")


func _ready():
	yield(owner, "ready")
	state.enter()
	actor.state_label.text = str(_state_name)


func _unhandled_input(event: InputEvent):
	state.unhandled_input(event)


func _process(delta):
	state.process(delta)


func _physics_process(delta):
	state.physics_process(delta)


func transition_to(target_state_path: String, msg: Dictionary = {}):
	if not has_node(target_state_path):
		return
	
	# Cache current state so we can retrieve the previous state
	previous_state = self.state
	
	var target_state := get_node(target_state_path)
	
	state.exit()
	self.state = target_state
	state.enter(msg)
	emit_signal("transitioned", target_state_path)


func set_state(value: State):
	state = value
	_state_name = state.name
	actor.state_label.text = str(_state_name)
