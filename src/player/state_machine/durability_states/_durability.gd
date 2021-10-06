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
export (float) var max_wait_time = 12.0
export (bool) var is_timer_active = true setget set_is_timer_active


func _ready():
#	_state_machine.connect("transitioned", self, "apply_durability_modifiers")
	decay_timer.connect("timeout", self, "_reduce_durability")
	DynamicMusicManager.animation_player.queue("solid")


func enter(_msg: Dictionary = {}):
	# FIXME - SOOOOOO MANY HACKJOBS
	yield(_actor.fadeout.animation_player, "animation_finished")
#	if is_timer_active:
#		_start_decay_timer()
	# Reset the durability timer
	if is_timer_active:
		reset_timer()


func _process(_delta):
	if is_timer_active:
		# Set the ui fill
		_actor.durability_ui.durability = (decay_timer.time_left / max_wait_time) * 100


func _reduce_durability():
	var new_state_index = _state_machine.state.get_index() + 1
	if new_state_index > 2:
		# Death
		_actor.state_machine.transition_to("Movement/Dead")
		_stop_decay_timer()
		return
	
	_actor.skin.switch_mesh(new_state_index)
	
	var new_state_name
	match new_state_index:
		0:
			new_state_name = "DurabilityParent/Solid"
			DynamicMusicManager.animation_player.queue("solid")
			_actor.switch_mesh(0)
		1:
			new_state_name = "DurabilityParent/Damaged"
			DynamicMusicManager.animation_player.queue("solid_to_damaged")
			_actor.switch_mesh(1)
		2:
			new_state_name = "DurabilityParent/Eroded"
			DynamicMusicManager.animation_player.queue("damaged_to_eroded")
			_actor.switch_mesh(2)
		_:
			push_error("Invalid durability state!")
	
	audio_manager.transition_to(audio_manager.States.DECAY)
	# If the player is running we want to swap the sounds out
	if _actor.state_machine.state.get_index() == 1:
		audio_manager.transition_walking_sfx(new_state_index)
	
	if is_timer_active:
		reset_timer()
	
	_state_machine.transition_to(new_state_name)


func _increase_durability():
	var new_state_index = _state_machine.state.get_index() - 1
	if new_state_index < 0:
		return
		
	_actor.skin.switch_mesh(new_state_index)
	
	var new_state_name
	match new_state_index:
		0:
			new_state_name = "DurabilityParent/Solid"
			DynamicMusicManager.animation_player.queue("damaged_to_solid")
			_actor.switch_mesh(0)
		1:
			new_state_name = "DurabilityParent/Damaged"
			DynamicMusicManager.animation_player.queue("eroded_to_damaged")
			_actor.switch_mesh(1)
		2:
			new_state_name = "DurabilityParent/Eroded"
			# Shouldn't happen unless we revive from death??
		_:
			push_error("Invalid durability state!")
	
	if is_timer_active:
		reset_timer()
	
	_state_machine.transition_to(new_state_name)


func reset_timer():
	decay_timer.wait_time = max_wait_time
	decay_timer.start()

func _start_decay_timer():
	# Reset the durability timer
	decay_timer.wait_time = max_wait_time
	_actor.durability_ui.animation_player.play("fade_in")
	yield(_actor.durability_ui.animation_player, "animation_finished")
	decay_timer.start()


func _stop_decay_timer():
	decay_timer.stop()
	_actor.durability_ui.animation_player.play("fade_out")


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
	
	# Set the ui colour
	_actor.durability_ui.color = state_colour
	

	
