extends State
# State for when the player is jumping

export var jump_velocity = 45

var dash_vector


func enter(_msg: Dictionary = {}):
	#	audio_player.transition_to(audio_player.States.JUMP)
	#	skin.transition_to(skin.States.JUMP)
	
	# Zero out any fall velocity before we apply the jump so we get the full height
	_parent.velocity = Vector3.ZERO
	# Allow wider aim range
	_actor.camera_pivot.is_aiming = true
	# Increase camera FOV
	# TODO - add in FOV slider support with this
	_actor.tween.interpolate_property(
		_actor.camera,
		"fov",
		_actor.camera.fov,
		_actor.camera.fov - 10,
		0.2,
		Tween.TRANS_EXPO,
		Tween.EASE_IN_OUT
	)
	_actor.tween.start()


func physics_process(delta: float):
	if _actor.is_on_ceiling():
		_parent.velocity.y = 0
	
	handle_rotation()
	
	if Input.is_action_just_pressed("p1_repair"):
		if _actor.pickup_count > 0:
			if _actor.durability_state_machine.state.get_index() > 0:
				_actor.pickup_count -= 1
				_actor.durability_state_machine.get_child(0)._increase_durability()
				#
				_state_machine.transition_to(
					"Movement/Falling",
					{"was_on_floor": false}
				)
			else:
				# Play invalid repair sound here
				pass
	elif Input.is_action_just_pressed("p1_unrepair"):
		if _actor.reverse_pickup_count > 0:
			if _actor.durability_state_machine.state.get_index() < 2:
				_actor.reverse_pickup_count -= 1
				_actor.durability_state_machine.get_child(0)._reduce_durability()
			else:
				# Play invalid repair sound here
				pass
	
	# Let go of the dash button to execute it
	if Input.is_action_just_released("p1_dash"):
		# FIXME - temp, replace this with the dash code
		_state_machine.transition_to(
			"Movement/AirDashing"
		)


func handle_rotation():
	# We calculate a move direction vector relative to the camera,
	# the basis stores the (right, up, -forwards) vectors of our camera.
	var forwards = _actor.camera.global_transform.basis.z
	var right = _actor.camera.global_transform.basis.x
	var move_direction = forwards + right
	
	if move_direction.length() > 1.0:
		move_direction = move_direction.normalized()
		move_direction.y = 0

	# Rotation
	if move_direction != Vector3.ZERO:
		# Get the angle in the y-axis via atan2
		var movement_angle = atan2(move_direction.x, move_direction.z) + PI
		# lerp_angle prevents the flip-flopping between 0 and 360 degrees
		_actor.rotation.y = lerp_angle(
			_actor.rotation.y,
			movement_angle,
			0.2
		)


func exit():
	_actor.camera_pivot.is_aiming = false
	_actor.tween.interpolate_property(
		_actor.camera,
		"fov",
		_actor.camera.fov,
		_actor.camera.fov + 10,
		0.2,
		Tween.TRANS_EXPO,
		Tween.EASE_IN_OUT
	)
	_actor.tween.start()
	_parent.exit()
