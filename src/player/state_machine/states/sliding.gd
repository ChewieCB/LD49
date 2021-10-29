extends State
# Basic state when the player is moving around until jumping or lack of input

export var max_speed = 100.0
export var move_speed = 20.0
export var gravity = -100.0
export var jump_impulse = 30

var slide_timer

var cached_base_collider_pos


func enter(_msg: Dictionary = {}):
	_parent.using_root_motion = true
	_parent.enter()
	_parent.max_speed = max_speed
	_parent.move_speed = move_speed
	_parent.jump_impulse = jump_impulse
	
	_actor.has_jumped = false
	_actor.has_dashed = false
	
	_actor.default_collider.disabled = true
	# Cache the collider positions for fallback
	cached_base_collider_pos = _actor.base_collider.transform.origin
	
	# AUDIO
	
#	var walk_sfx = get_walk_sfx()
#	audio_manager.transition_to(walk_sfx)
	
	# MESH
	var skin = _actor.skin
	skin.transition_to(skin.States.SLIDE)
	skin.animation_player.connect("animation_finished", self, "slide_finished")
	
	_actor.climbing_rays.transform.origin = _actor.climb_ray_pos_normal
	
	var slide_anim = skin.animation_player.get_animation("slide")
	slide_timer = Timer.new()
	slide_timer.wait_time = slide_anim.length
	slide_timer.connect("timeout", self, "slide_finished")
	add_child(slide_timer)
	slide_timer.start()


#func get_walk_sfx():
#	var walk_sfx_state
#	# FIXME - this really needs to be an actor level variable
#	match _actor.durability_parent._state_machine.state.get_index():
#		# Solid - slowest
#		0:
#			walk_sfx_state = audio_manager.States.MOVE_SLOW
#		# Damaged - medium
#		1:
#			walk_sfx_state = audio_manager.States.MOVE_MEDIUM
#		# Eroded - fastest
#		2:
#			walk_sfx_state = audio_manager.States.MOVE_FAST
#
#	return walk_sfx_state


func unhandled_input(event: InputEvent):
	_parent.unhandled_input(event)


func physics_process(delta: float):
	_parent.physics_process(delta)
	
	if _actor.skin.highest_foot:
		_actor.default_collider.global_transform.origin.y = _actor.skin.highest_foot.global_transform.origin.y + 3.2
		_actor.base_collider.global_transform.origin.y = _actor.skin.highest_foot.global_transform.origin.y + 1.3
	
	if _actor.is_on_floor():
		# Jumping
		if Input.is_action_pressed("p1_jump"):
			_state_machine.transition_to("Movement/Jumping")
	# Falling
#	else:
#		if _parent.velocity.y < -1:
#			_state_machine.transition_to(
#				"Movement/Falling",
#				{"was_on_floor": true}
#				)
	

func slide_finished():
	_state_machine.transition_to("Movement/Idle")


func exit():
	_actor.default_collider.disabled = false
	_actor.base_collider.transform.origin = cached_base_collider_pos
	if slide_timer and not slide_timer.is_stopped():
		slide_timer.stop()
		slide_timer.queue_free()
	_parent.exit()
