extends Control

var main_menu_path = "res://src/ui/main_menu/Menu.tscn"

onready var animation_player = $AnimationPlayer
onready var fadeout = $"../Fadeout"

onready var player = get_node("../../PlayerRig/Player")


func _ready():
	animation_player.play("default")


func fade_in():
	animation_player.play("fade_in")
	yield(animation_player, "animation_finished")


func reset_bgm_mix():
	match player.durability_state_machine.state.get_index():
			0:
				DynamicMusicManager.animation_player.play("solid")
			1:
				DynamicMusicManager.animation_player.play("damaged_to_solid")
			2:
				DynamicMusicManager.animation_player.play("eroded_to_solid")


func _on_RetryButton_pressed():
	fadeout.fade_out(0.5)
	reset_bgm_mix()
	animation_player.play("default")
	yield(fadeout.animation_player, "animation_finished")
	yield(DynamicMusicManager.animation_player, "animation_finished")
	get_tree().reload_current_scene()


func _on_QuitButton_pressed():
	fadeout.fade_out(0.5)
	yield(fadeout.animation_player, "animation_finished")
	get_tree().change_scene(main_menu_path)

