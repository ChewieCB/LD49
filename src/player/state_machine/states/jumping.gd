extends State
# State for when the player is jumping

export var jump_velocity = 35


func enter(_msg: Dictionary = {}):
	_parent.enter()
#	_parent.velocity.x *= 2
#	_parent.velocity.z *= 2
	_parent.velocity += Vector3(0, jump_velocity * _parent.jump_impulse_modifier, 0)
	_actor.has_jumped = true
	
	#
#	audio_player.transition_to(audio_player.States.JUMP)
#	skin.transition_to(skin.States.JUMP)


func physics_process(delta: float):
	_parent.physics_process(delta)
	if _actor.is_on_ceiling():
		_parent.velocity.y = 0
	
	if Input.is_action_just_pressed("p1_jump"):
		if _actor.can_mantle():
			_state_machine.transition_to("Movement/Climbing")
		# We only want double jumping available at lower durability
		elif _actor.durability_state_machine.state.get_index() > 0:
			_state_machine.transition_to("Movement/DoubleJumping")
	
	elif Input.is_action_pressed("p1_dash") and not _actor.has_dashed:
		# We only want air dashing available at lower durability
		if _actor.durability_state_machine.state.get_index() > 0:
			_state_machine.transition_to("Movement/AirDashingAiming")
	
	# Transition to Falling at peak of jump
	if _parent.velocity.y <= 0:
		_state_machine.transition_to(
				"Movement/Falling",
				{"was_on_floor": false}
			)


func exit():
	_parent.exit()
