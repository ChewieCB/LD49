extends State

signal dead


func enter(msg: Dictionary = {}):
	# Disable player input
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = false
	_actor.is_dead = true
	_actor.has_jumped = false
	_actor.has_dashed = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#
	_parent.using_root_motion = true
	_parent.enter()
	_parent.input_direction = Vector3.ZERO
#	_parent.move_direction = Vector3.ZERO
	#
	audio_manager.transition_to(audio_manager.States.DIE, 1)
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.DIE)
	# Ragdoll 
#	skin._start_ragdoll()
	
	#
	emit_signal("dead")


func physics_process(delta: float):
	_parent.physics_process(delta)


func exit():
	pass
#	skin._stop_ragdoll()
#	# Re-enable player input
#	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
#	GlobalFlags.CAMERA_CONTROLS_ACTIVE = true

