extends State

#export var gravity = -80.0
export (float) var vertical_move_time = 0.6
export (float) var horizontal_move_time = 0.4

var climb_direction
var tween


func _ready():
	yield(owner, "ready")
	
	skin = _actor.skin
	skin.connect("climb_up", self, "climb_up")
	skin.connect("climb_across", self, "climb_across")
	skin.connect("climb_end", self, "_exit_climb")
	
	tween = _actor.tween
	

func enter(_msg: Dictionary = {}):
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	
	_parent.velocity = Vector3.ZERO
#	_parent.gravity = 0.0
	_parent.enter()
	
	climb_direction = get_climb_direction()
	
	# MESH
	skin = _actor.skin
	skin.transition_to(skin.States.CLIMB)

	#
	audio_manager.transition_to(audio_manager.States.CLIMB)
	
#	var skin = _actor.skin
#	skin.transition_to(skin.States.CLIMB)
#	skin.transition_to(skin.States.IDLE)


func physics_process(_delta):
	var velocity = _actor.move_and_slide(skin.root_motion_velocity, Vector3.UP, true, 4, 0.785398, false)
	
	if Input.is_action_just_pressed("p1_repair"):
		if _actor.pickup_count > 0:
			_actor.pickup_count -= 1
			_actor.durability_state_machine.get_child(0)._increase_durability()
	elif Input.is_action_just_pressed("p1_unrepair"):
		if _actor.reverse_pickup_count > 0:
			_actor.reverse_pickup_count -= 1
			_actor.durability_state_machine.get_child(0)._reduce_durability()


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func exit():
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
	
#	_parent.gravity = gravity
	_parent.exit()


func grab_ledge():
	pass


func climb_up():
	tween.stop_all()
	
	var vertical_movement = _actor.global_transform.origin + Vector3(0, 2.2, 0) + _actor.climbing_rays.transform.origin
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		_actor.global_transform.origin, 
		vertical_movement,
		vertical_move_time * _parent.climb_speed_modifier, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN_OUT
	)
	tween.start()

func climb_across():
#	yield(tween, "tween_all_completed")
	var forward_movement = _actor.global_transform.origin + (climb_direction * 4.0)
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		_actor.global_transform.origin, 
		forward_movement,
		horizontal_move_time * _parent.climb_speed_modifier, 
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	tween.start()
	
	yield(tween, "tween_all_completed")
	_state_machine.transition_to("Movement/Falling", {"was_on_floor": false})


func get_climb_direction():
	for _ray in _actor.body_rays.get_children():
		if _ray.is_colliding():
			return -_ray.get_collision_normal()
	
	return Vector3.ZERO

