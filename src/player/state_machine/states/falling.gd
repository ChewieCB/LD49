extends State
# State for when the player is falling

onready var coyote_time = Timer.new()
onready var was_on_floor = false

export var max_speed = 20.0
export var move_speed = 20.0
export var gravity = -80.0
export var jump_impulse = 30


func enter(msg: Dictionary = {}):
	_parent.enter()
	_parent.max_speed = max_speed
	_parent.move_speed = move_speed
	_parent.jump_impulse = jump_impulse
	#
#	audio_player.transition_to(audio_player.States.FALL)
	
	match msg:
		{"was_on_floor": var _was_on_floor}:
			was_on_floor = _was_on_floor
	# Add coyote timer if falling off a ledge
	if was_on_floor:
		coyote_time.one_shot = true
		coyote_time.wait_time = 0.2
		if not coyote_time.is_connected("timeout", self, "_on_coyote_time_timeout"):
			coyote_time.connect("timeout", self, "_on_coyote_time_timeout")
		if not coyote_time in get_children():
			add_child(coyote_time)
			coyote_time.start()


func physics_process(delta: float):
	_parent.physics_process(delta)
	if _actor.is_on_floor():
		if _parent.input_direction == Vector3.ZERO:
			# Idle
			_state_machine.transition_to("Movement/Idle")
		else:
			# Walking
			_state_machine.transition_to("Movement/Running")
	else:
		if Input.is_action_just_pressed("p1_jump") and _actor.can_mantle():
			_state_machine.transition_to("Movement/Climbing")
		# Coyote Time jumping
		if Input.is_action_pressed("p1_jump") and not coyote_time.is_stopped():
			coyote_time.stop()
			_state_machine.transition_to(
				"Movement/Jumping",
				{"was_on_floor": _actor.is_on_floor()}
			)


func exit():
#	audio_player.transition_to(audio_player.States.LAND)
	_parent.exit()


func _on_coyote_time_timeout():
	remove_child(coyote_time)
