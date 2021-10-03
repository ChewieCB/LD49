extends State
# State for when there is no movement input
# Supports triggering jump after the player has started to fall
export var move_speed_modifier = 1.6
export var climb_speed_modifier = 0.05
#
export var weight = 0
export var jump_impulse_modifier = 1.2
export var gravity_modifier = 0.9

var state_colour = Color.red
export var health = 2


func enter(_msg: Dictionary = {}):
	_parent.move_speed_modifier = move_speed_modifier
	_parent.climb_speed_modifier = climb_speed_modifier
	#
	_parent.weight = weight
	_parent.jump_impulse_modifier = jump_impulse_modifier
	_parent.gravity_modifier = gravity_modifier
	#
	_parent.state_colour = state_colour
	_parent.health = health
	#
	_parent.enter()
	
	#
#	skin = SOLID_SKIN
#	yield(audio_player.audio_player, "finished")
#	audio_player.stop_audio()


func exit():
	_parent.exit()
