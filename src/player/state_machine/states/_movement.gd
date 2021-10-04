extends State
# Parent state for all movement-related states for the Player
# Holds all of the base movement logic
# Child states can override this states's functions or change its properties
# This keeps the logic grouped in one location

signal main_menu

# These should be fallback defaults
# TODO: Make these null and raise an exception to indicate bad State extension
#       to better separate movement vars.
export var max_speed = 100
export var move_speed = 20
export var gravity = -100.0
export var jump_impulse = 35

var move_speed_modifier = 1.0
var climb_speed_modifier = 1.0
var jump_impulse_modifier = 1.0
var gravity_modifier = 1.0

var velocity := Vector3.ZERO
var input_direction = Vector3.ZERO
var move_direction = Vector3.ZERO


func _ready():
	yield(owner, "ready")
	_actor.durability_state_machine.connect(
		"transitioned",
		self,
		"_apply_movement_modifiers"
	)
	self.connect("main_menu", DynamicMusicManager, "main_menu")


func enter(_msg: Dictionary = {}):
	yield(_actor.fadeout.animation_player, "animation_finished")


func physics_process(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		_actor.fadeout.fade_out(0.5)
		yield(_actor.fadeout.animation_player, "animation_finished")
		emit_signal("main_menu")
		yield(DynamicMusicManager, "bgm_changed")
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var main_menu_path = "res://src/ui/main_menu/Menu.tscn"
		get_tree().change_scene(main_menu_path)
	
	# Debug Reset
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_pressed("quit"):
		get_tree().quit()
	
	if GlobalFlags.PLAYER_CONTROLS_ACTIVE:
		if Input.is_action_just_pressed("p1_repair"):
			if GlobalFlags.DEBUG_POWERUPS:
				_actor.durability_state_machine.get_child(0)._increase_durability()
				audio_manager.transition_to(audio_manager.States.USE_ADD)
			else:
				if _actor.pickup_count > 0:
					if _actor.durability_state_machine.state.get_index() > 0:
						_actor.pickup_count -= 1
						_actor.durability_state_machine.get_child(0)._increase_durability()
						#
						audio_manager.transition_to(audio_manager.States.USE_ADD)
					else:
						# Play invalid repair sound here
						audio_manager.transition_to(audio_manager.States.EMPTY)
		elif Input.is_action_just_pressed("p1_unrepair"):
			if GlobalFlags.DEBUG_POWERUPS:
				_actor.durability_state_machine.get_child(0)._reduce_durability()
				audio_manager.transition_to(audio_manager.States.USE_REMOVE)
			else:
				if _actor.reverse_pickup_count > 0:
					if _actor.durability_state_machine.state.get_index() < 2:
						_actor.reverse_pickup_count -= 1
						_actor.durability_state_machine.get_child(0)._reduce_durability()
						#
						audio_manager.transition_to(audio_manager.States.USE_REMOVE)
					else:
						# Play invalid repair sound here
						audio_manager.transition_to(audio_manager.States.EMPTY)
	
	# Movement
	if GlobalFlags.PLAYER_CONTROLS_ACTIVE:
		input_direction = get_input_direction()
	else:
		input_direction = Vector3.ZERO
	
	move_direction = calculate_movement_direction(input_direction, delta)
	
	velocity = calculate_velocity(velocity, move_direction, delta)
	velocity = _actor.move_and_slide(velocity, Vector3.UP, true, 4, 0.785398, false)


func get_input_direction():
	var input_vector =  Vector3(
		Input.get_action_strength("p1_move_right") - Input.get_action_strength("p1_move_left"),
		0,
		Input.get_action_strength("p1_move_backwards") - Input.get_action_strength("p1_move_forwards")
	)
	
	return input_vector


func calculate_movement_direction(input_direction, delta):
	var forwards := Vector3.ZERO
	var right := Vector3.ZERO
	
	# We calculate a move direction vector relative to the camera,
	# the basis stores the (right, up, -forwards) vectors of our camera.
	#
	# FIXME - ugh these alignments are a MESS
	forwards = input_direction.z * _actor.transform.basis.x
	right = input_direction.x * - _actor.transform.basis.z
	move_direction = forwards + right
	
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
#		for element in _actor.rotateable:
#			element.rotation.y = lerp_angle(
#				element.rotation.y,
#				movement_angle,
#				0.2
#			)

	return move_direction 


func calculate_velocity(velocity_current: Vector3, move_direction: Vector3, delta: float):
	var velocity_new = move_direction * (move_speed * move_speed_modifier)
	if velocity_new.length() > max_speed:
		velocity_new = velocity_new.normalized() * max_speed
	velocity_new.y = velocity_current.y + (gravity * gravity_modifier) * delta
	
	return velocity_new


func _apply_movement_modifiers(new_state):
	# Apply movement modifiers from the player's durability state
	var current_durability_state = _actor.durability_state_machine.state
	
	move_speed_modifier = current_durability_state.move_speed_modifier
	jump_impulse_modifier = current_durability_state.jump_impulse_modifier
	gravity_modifier = current_durability_state.gravity_modifier

