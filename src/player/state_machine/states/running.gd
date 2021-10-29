extends State
# Basic state when the player is moving around until jumping or lack of input

export var max_speed = 100.0
export var move_speed = 20.0
export var gravity = -100.0
export var jump_impulse = 30

var skin_direction = Vector2.ZERO


func enter(_msg: Dictionary = {}):
	_parent.using_root_motion = true
	_parent.enter()
	_parent.max_speed = max_speed
	_parent.move_speed = move_speed
	_parent.jump_impulse = jump_impulse
	
	_actor.has_jumped = false
	_actor.has_dashed = false
	
	# AUDIO
	
	var walk_sfx = get_walk_sfx()
	audio_manager.transition_to(walk_sfx)
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.RUN)
	
	_actor.climbing_rays.transform.origin = _actor.climb_ray_pos_normal


func get_walk_sfx():
	var walk_sfx_state
	# FIXME - this really needs to be an actor level variable
	match _actor.durability_parent._state_machine.state.get_index():
		# Solid - slowest
		0:
			walk_sfx_state = audio_manager.States.MOVE_SLOW
		# Damaged - medium
		1:
			walk_sfx_state = audio_manager.States.MOVE_MEDIUM
		# Eroded - fastest
		2:
			walk_sfx_state = audio_manager.States.MOVE_FAST
	
	return walk_sfx_state


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	if Input.is_action_just_pressed("p1_slide"):
		_state_machine.transition_to("Movement/Sliding")
	
	# Apply input direction to skin
	var input_direction = Vector2(
		_parent.input_direction.x,
		# Z direction is negative
		- _parent.input_direction.z
	)
	skin_direction = lerp(skin_direction, input_direction, 0.1)
	_actor.skin.animation_tree.set(
		"parameters/running/run_blend/blend_position", 
		skin_direction
	)
	# TODO - only apply this on change, add a setter or signal
	# Apply timescale to blend space
	_actor.skin.animation_tree.set(
		"parameters/running/run_speed/scale", 
		_parent.move_speed_modifier - 0.2
	)
	
	# Idle
	if _parent.input_direction == Vector3.ZERO:
		_state_machine.transition_to("Movement/Idle")
	else:
		if _actor.is_on_floor():
			# Jumping
			if Input.is_action_pressed("p1_jump"):
				_state_machine.transition_to("Movement/Jumping")
		# Falling
		else:
			if _parent.velocity.y < 0:
				_state_machine.transition_to(
					"Movement/Falling",
					{"was_on_floor": true}
				)


func exit():
	_parent.exit()
