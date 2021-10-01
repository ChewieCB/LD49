extends Control


onready var color_rect = $ColorRect
onready var animation_player = $AnimationPlayer


func fade_in(time: float):
	_play_fade_animation(true, time)


func fade_out(time: float):
	_play_fade_animation(false, time)


func _play_fade_animation(fade_in: bool, time: float):
	# Construct the animation name
	var anim_name = _get_anim_name(fade_in, time)
	
	if not animation_player.has_animation(anim_name):
		var new_anim = _create_fade_animation(fade_in, time)
		animation_player.add_animation(anim_name, new_anim)
	
	print(anim_name)
	animation_player.queue(anim_name)


func _get_anim_name(fade_in: bool, time: float):
	var fade_type
	match fade_in:
		true:
			fade_type = "in"
		false:
			fade_type = "out"
	
	return "fade_%s_%ss" % [fade_type, time]


func _create_fade_animation(fade_in: bool, time: float):
	var anim = Animation.new()
	# Setup a single track for changing the transparency of the colour rect
	anim.add_track(Animation.TYPE_VALUE, 0)
	anim.track_set_path(0, String(color_rect.get_path()) + ":modulate")
	anim.length = time
	# Assign the transparency value keys to the animation depending on wether
	# we are fading in or out.
	match fade_in:
		true:
			anim.track_insert_key(0, 0.0, Color(1.0, 1.0, 1.0, 1.0))
			anim.track_insert_key(0, time, Color(1.0, 1.0, 1.0, 0.0))
		false:
			anim.track_insert_key(0, 0.0, Color(1.0, 1.0, 1.0, 0.0))
			anim.track_insert_key(0, time, Color(1.0, 1.0, 1.0, 1.0))
	
	return anim
