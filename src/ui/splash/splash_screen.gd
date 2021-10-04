extends Control

export (float) var splash_time_in = 0.5
export (float) var splash_time_hold = 1.0
export (float) var splash_time_out = 0.5

onready var fadeout = $GUI/Fadeout
onready var main_menu = "res://src/ui/main_menu/Menu.tscn"


func _ready():
#	DynamicMusicManager.level_id = 0
	fadeout.fade_in(splash_time_in)
	yield(fadeout.animation_player, "animation_finished")
	
	yield(get_tree().create_timer(splash_time_hold), "timeout")
	
	fadeout.fade_out(splash_time_out)
	yield(fadeout.animation_player, "animation_finished")
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_tree().change_scene(main_menu)

