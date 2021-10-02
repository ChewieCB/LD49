extends State
# State for when the player is jumping

export var jump_velocity = 35


func enter(_msg: Dictionary = {}):
	_parent.enter()
#	_parent.velocity.x *= 2
#	_parent.velocity.z *= 2
	_parent.velocity += Vector3(0, jump_velocity, 0)
	
	#
#	audio_player.transition_to(audio_player.States.JUMP)
#	skin.transition_to(skin.States.JUMP)


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
