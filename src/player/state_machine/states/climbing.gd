extends State

#export var gravity = -80.0
export (float) var vertical_move_time = 0.6
export (float) var horizontal_move_time = 0.4

var climb_direction


func enter(_msg: Dictionary = {}):
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = false
	
	_parent.using_root_motion = true
	_parent.velocity = Vector3.ZERO
#	_parent.gravity = 0.0
	_parent.enter()
	
	climb_direction = get_climb_direction()
	
	# MESH
	var skin = _actor.skin
	skin.high_vert = find_vertical_edge(climb_direction)
	skin.transition_to(skin.States.CLIMB)
	
	climb()

	#
	audio_manager.transition_to(audio_manager.States.CLIMB)


func physics_process(_delta):
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


func climb():
	var tween = _actor.tween
	
	var climb_height = _actor.skin.high_vert.y - _actor.global_transform.origin.y
	
	var vertical_movement = _actor.global_transform.origin + Vector3(0, climb_height, 0)
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		_actor.global_transform.origin, 
		vertical_movement,
		vertical_move_time * _parent.climb_speed_modifier, 
		Tween.TRANS_CUBIC, 
		Tween.EASE_IN
	)
	tween.start()
	
	yield(tween, "tween_all_completed")
	var forward_movement = _actor.global_transform.origin + (climb_direction * 2.4)
	tween.interpolate_property(
		_actor, 
		"global_transform:origin", 
		_actor.global_transform.origin, 
		forward_movement,
		horizontal_move_time * _parent.climb_speed_modifier, 
		Tween.TRANS_QUAD,
		Tween.EASE_OUT_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	_state_machine.transition_to("Movement/Falling", {"was_on_floor": false})


func get_climb_direction():
	for _ray in _actor.body_rays.get_children():
		if _ray.is_colliding():
			return -_ray.get_collision_normal()
	
	return Vector3.ZERO


func find_vertical_edge(climb_direction):
	var edge_vert
	
	# Find out which raycasts are already colliding, we can use these
	# as a start point.
	var climb_rays = [
		_actor.skin.left_hand_ray, 
		_actor.skin.right_hand_ray,
		_actor.skin.chest_ray_1,
		_actor.skin.chest_ray_2
	]
	# Add the actual climbing raycasts as well for good measure/fallback
	climb_rays.append_array(_actor.body_rays.get_children())
	var collision_rays = []
	for ray in climb_rays:
		if ray.is_colliding():
			collision_rays.append(ray)
	
	# We can't find the edge if we have no start point
	if not collision_rays:
		return
	# Find the highest existing collision point, this decreases the amount of
	# new raycasts we have to make - improving performance.
	collision_rays.sort_custom(self, "sort_highest_ray")
	var highest_ray = collision_rays[0]
	
	# Create a new, movable raycast from the highest current colliding ray
	var ray_start = highest_ray.global_transform.origin
	var ray_end = ray_start + climb_direction * 4
	var edge_finder_raycast = _actor.space_state.intersect_ray(
		ray_start,
		ray_end
	)
	# Draw initial ray collision for debug
#	_actor._generate_ik_debug([ray_end], Color.yellow)
	
	# Keep moving the raycast incrementally higher until the raycast is no
	# longer collding with the climbing mesh
	#
	# TODO - for micro-optimisations look at marching rays/cubes algorithm?
	while edge_finder_raycast:
		edge_vert = edge_finder_raycast.position
		ray_start.y += 0.2
		ray_end.y += 0.2
		
		# Draw test rays for debug
#		_actor._generate_ik_debug([edge_vert], Color.gray)
		
		edge_finder_raycast = _actor.space_state.intersect_ray(
			ray_start,
			ray_end
		)
	
	# Draw final edge ray for debug
#	_actor._generate_ik_debug([edge_vert], Color.green)
	
	# Set the high_vert y value to the last successful collision point
	return edge_vert


func sort_highest_ray(a: RayCast, b: RayCast):
	if a.get_collision_point().y > b.get_collision_point().y:
		return true
	return false

