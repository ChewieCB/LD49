extends State

#export var gravity = -80.0
export (float) var vertical_move_time = 0.4
export (float) var horizontal_move_time = 0.2


func enter(_msg: Dictionary = {}):
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	
	_parent.velocity = Vector3.ZERO
#	_parent.gravity = 0.0
	_parent.enter()
	
	climb()
	#
#	skin.transition_to(skin.States.IDLE)
#	yield(audio_player.audio_player, "finished")
#	audio_player.stop_audio()


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)
	if _actor.is_on_floor():
		# Stationary Jumping
		if Input.is_action_pressed("p1_jump"):
			_state_machine.transition_to("Movement/Jumping")
		if _parent.input_direction != Vector3.ZERO:
			# Walking
			for _input in ["p1_move_forwards", "p1_move_left", "p1_move_backwards", "p1_move_right"]:
				if Input.is_action_pressed(_input):
					_state_machine.transition_to("Movement/Running")
		elif _parent.velocity.y < -0.1:
			_state_machine.transition_to(
				"Movement/Falling",
				{"was_on_floor": _actor.is_on_floor()}
			)


func exit():
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
	
#	_parent.gravity = gravity
	_parent.exit()


func grab_ledge():
	pass


func climb():
	var tween = _actor.tween
	
	var climb_direction = get_climb_direction()
	
	var vertical_movement = _actor.global_transform.origin + Vector3(0, 3, 0)
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		null, 
		vertical_movement,
		vertical_move_time, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN
	)
	tween.start()
	
	yield(tween, "tween_all_completed")
	var forward_movement = _actor.global_transform.origin + (climb_direction * 2.0)
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		null, 
		forward_movement,
		horizontal_move_time, 
		Tween.TRANS_LINEAR
	)
	tween.start()
	yield(tween, "tween_all_completed")
	_state_machine.transition_to("Movement/Idle")


func get_climb_direction():
	for _ray in _actor.body_rays.get_children():
		if _ray.is_colliding():
			return -_ray.get_collision_normal()
	
	return Vector3.ZERO

