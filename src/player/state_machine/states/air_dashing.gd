extends State
# State for when the player is jumping

export var jump_velocity = 100
export var gravity = 0.0

onready var dash_timer = $DashTimer
export (float) var dash_time = 0.3

var dash_velocity


func enter(msg: Dictionary = {}):
	_parent.using_root_motion = false
	audio_manager.transition_to(audio_manager.States.AIR_DASH, 1)
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.DASH)
	
	dash_timer.wait_time = dash_time
	dash_timer.start()
	
	# Prevent the player from double dashing
	_actor.has_dashed = true
	
	# Let the player dash through grate objects
	_actor.set_collision_mask_bit(3, false)

	# Yeet the player forwards in the direction the camera is facing	
	dash_velocity = -_actor.camera.global_transform.basis.z
	dash_velocity *= jump_velocity


func physics_process(delta: float):
	if _actor.is_on_ceiling():
		_parent.velocity.y = 0
	
	handle_rotation()
	
	if Input.is_action_just_pressed("p1_repair"):
		if _actor.pickup_count > 0:
			if _actor.durability_state_machine.state.get_index() > 0:
				_actor.pickup_count -= 1
				_actor.durability_state_machine.get_child(0)._increase_durability()
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
	
	if Input.is_action_just_pressed("p1_jump") and _actor.can_mantle():
		_state_machine.transition_to("Movement/Climbing")
	
	dash_velocity.y += delta * gravity
	_actor.move_and_slide(dash_velocity, Vector3.UP, false, 4, 0.785398, false)
	


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
	_actor.set_collision_mask_bit(3, true)
	_parent.exit()


func _on_DashTimer_timeout():
	_state_machine.transition_to(
		"Movement/Falling",
		{"was_on_floor": false}
	)
