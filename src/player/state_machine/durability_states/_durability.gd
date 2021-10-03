extends State

#
var move_speed_modifier = null
var climb_speed_modifier = null
#
var weight = null
var jump_impulse_modifier = null
var gravity_modifier = null
#
var health = null

var state_colour = Color.white setget set_state_colour
onready var decay_timer = $"../DecayTimer"
export (bool) var is_timer_active = true setget set_is_timer_active


func _ready():
#	_state_machine.connect("transitioned", self, "apply_durability_modifiers")
	decay_timer.connect("timeout", self, "_reduce_durability")


func enter(_msg: Dictionary = {}):
	audio_player = null #_actor.audio_player
	skin = null #_actor.skin
	
	# Reset the durability timer
	if is_timer_active:
		decay_timer.stop()
		decay_timer.wait_time = 15.0
		decay_timer.start()


func _reduce_durability():
	var new_state_index = _state_machine.state.get_index() + 1
	if new_state_index > 2:
		# Death
		_actor.state_machine.transition_to("Movement/Dead")
		decay_timer.stop()
		return
	
	var new_state_name
	match new_state_index:
		0:
			new_state_name = "DurabilityParent/Solid"
		1:
			new_state_name = "DurabilityParent/Damaged"
		2:
			new_state_name = "DurabilityParent/Eroded"
		_:
			push_error("Invalid durability state!")
	
	print("Changing to %s" % [new_state_name])
	_state_machine.transition_to(new_state_name)


func _increase_durability():
	var new_state_index = _state_machine.state.get_index() - 1
	if new_state_index < 0:
		if is_timer_active:
			decay_timer.stop()
			decay_timer.wait_time = 10.0
			decay_timer.start()
		return
	
	var new_state_name
	match new_state_index:
		0:
			new_state_name = "DurabilityParent/Solid"
		1:
			new_state_name = "DurabilityParent/Damaged"
		2:
			new_state_name = "DurabilityParent/Eroded"
		_:
			push_error("Invalid durability state!")
	
	print("Changing to %s" % [new_state_name])
	_state_machine.transition_to(new_state_name)


func _start_decay_timer():
	# Reset the durability timer
	decay_timer.wait_time = 15.0
	decay_timer.start()


func _stop_decay_timer():
	decay_timer.stop()


func set_is_timer_active(value):
	is_timer_active = value
	if is_timer_active:
		_start_decay_timer()
	else:
		_stop_decay_timer()


func set_state_colour(value: Color):
	state_colour = value
	var material = _actor.debug_mesh.get_surface_material(0)
	material.set_albedo(state_colour)
	_actor.debug_mesh.set_surface_material(0, material)
