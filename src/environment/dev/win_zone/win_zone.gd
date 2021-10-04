extends Spatial

onready var fadeout = $"../GUI/Fadeout"

export (String) var next_level_path


func finish_level():
	# STRETCH GOAL - zoom a camera through the blackened door as a transition
	#
	# Fadeout
	fadeout.fade_out(1.0)
	yield(fadeout.animation_player, "animation_finished")
	
	DynamicMusicManager.advance_level()
	
	# Load next level
	if next_level_path:
		get_tree().change_scene(next_level_path)
	else:
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().reload_current_scene()


func _on_Area_body_entered(body):
	if body is PlayerController:
		finish_level()
