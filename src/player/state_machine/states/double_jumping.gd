extends State
# State for when the player is jumping

export var jump_velocity = 25


func enter(_msg: Dictionary = {}):
	_parent.enter()
#	_parent.velocity.x *= 2
#	_parent.velocity.z *= 2
	# Zero out any fall velocity before we apply the jump so we get the full height
	_parent.velocity.y = 0
	_parent.velocity += Vector3(0, jump_velocity * _parent.jump_impulse_modifier, 0)
	
	_actor.has_jumped = false
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.DOUBLE_JUMP)
	#
	audio_manager.transition_to(audio_manager.States.DOUBLE_JUMP)


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	if _actor.is_on_ceiling():
		_parent.velocity.y = 0
	
	if Input.is_action_just_pressed("p1_jump") and _actor.can_mantle():
		_state_machine.transition_to("Movement/Climbing")
	
	# Transition to Falling at peak of jump
	if _parent.velocity.y <= 0:
		_state_machine.transition_to(
				"Movement/Falling",
				{"was_on_floor": false}
			)


func exit():
	_parent.exit()
