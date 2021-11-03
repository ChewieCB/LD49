extends State
# State for when the player is jumping

export var jump_velocity = 35

var skin_direction = 0

# FIXME - remove ROOT MOTION from jumping, it's really hard to control and
# prevents sideways jumps :/


func enter(_msg: Dictionary = {}):
	_parent.using_root_motion = false
	_parent.enter()
#	_parent.velocity.x *= 2
#	_parent.velocity.z *= 2
	_parent.velocity += Vector3(0, jump_velocity * _parent.jump_impulse_modifier, 0)
	_actor.has_jumped = true
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.JUMP)
	#
	audio_manager.transition_to(audio_manager.States.JUMP, 0)
	
	_actor.climbing_rays.transform.origin = _actor.climb_ray_pos_jump


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	# Apply input direction to skin
	var input_direction = - _parent.input_direction.z
	skin_direction = lerp(skin_direction, input_direction, 0.1)
	_actor.skin.animation_tree.set(
		"parameters/jump/jump_blend/blend_position", 
		skin_direction
	)
	
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
		if _actor.durability_state_machine.state.get_index() > 1:
			_state_machine.transition_to("Movement/AirDashingAiming")
	
	# Transition to Falling at peak of jump
	if _parent.velocity.y <= 0:
		_state_machine.transition_to(
				"Movement/Falling",
				{"was_on_floor": false}
			)


func exit():
	_parent.exit()
