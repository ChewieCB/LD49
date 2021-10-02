extends State

signal dead


func enter(msg: Dictionary = {}):
	# Disable player input
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = false
	_actor.is_dead = true
	_actor.has_jumped = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#
	_parent.enter()
	_parent.input_direction = Vector3.ZERO
#	_parent.move_direction = Vector3.ZERO
	#
#	audio_player.transition_to(audio_player.States.DROWN)
#	skin.transition_to(skin.States.DROWN)
	# TODO - add ragdoll in here when we get a rigged player mesh
	# https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html
	#
	emit_signal("dead")


func physics_process(delta: float):
	_parent.physics_process(delta)


#func exit():
#	# Re-enable player input
#	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
#	GlobalFlags.CAMERA_CONTROLS_ACTIVE = true

