extends State
# State for when the player is falling

onready var coyote_time = $CoyoteTimer
onready var was_on_floor = false

export var max_speed = 100.0
export var move_speed = 20.0
export var gravity = -120.0
export var jump_impulse = 30


func _ready():
	coyote_time.connect("timeout", self, "_on_coyote_time_timeout")


func enter(msg: Dictionary = {}):
	_parent.using_root_motion = false
	_parent.enter()
	_parent.max_speed = max_speed
	_parent.move_speed = move_speed
	_parent.jump_impulse = jump_impulse
	#
	audio_manager.transition_to(audio_manager.States.IDLE, 0)
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.FALL)
	
	match msg:
		{"was_on_floor": var _was_on_floor}:
			was_on_floor = _was_on_floor
	# Add coyote timer if falling off a ledge
	if was_on_floor:
		coyote_time.one_shot = true
		coyote_time.wait_time = _parent.move_speed_modifier
		coyote_time.start()


func physics_process(delta: float):
	_parent.physics_process(delta)
	if _actor.is_on_floor():
		if _parent.input_direction == Vector3.ZERO:
			# Idle
#			audio_manager.transition_to(audio_manager.States.LAND, 1)
			_state_machine.transition_to("Movement/Idle")
		else:
			# Walking
#			audio_manager.transition_to(audio_manager.States.LAND, 1)
			_state_machine.transition_to("Movement/Running")
	else:
		if Input.is_action_pressed("p1_jump"):
			if _actor.can_mantle():
				_state_machine.transition_to("Movement/Climbing")
		if Input.is_action_just_pressed("p1_jump"):
			if _actor.has_jumped:
				if _actor.durability_state_machine.state.get_index() > 0:
					_state_machine.transition_to("Movement/DoubleJumping")
			# Coyote Time jumping
			if not coyote_time.is_stopped():
				coyote_time.stop()
				_state_machine.transition_to(
					"Movement/Jumping",
					{"was_on_floor": _actor.is_on_floor()}
				)
		elif Input.is_action_pressed("p1_dash") and not _actor.has_dashed:
			# We only want air dashing available at lower durability
			if _actor.durability_state_machine.state.get_index() > 1:
				_state_machine.transition_to("Movement/AirDashingAiming")


func exit():
	_parent.exit()


func _on_coyote_time_timeout():
	pass
#	remove_child(coyote_time)

