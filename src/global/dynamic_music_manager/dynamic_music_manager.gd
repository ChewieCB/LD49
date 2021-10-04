extends Node

signal bgm_changed

export (int) var level_id setget set_level_id
export (int) var current_state = 0

# Main Menu
export (AudioStream) var main_menu_bgm
# Level 1
export (AudioStream) var level_1_solid_bgm
export (AudioStream) var level_1_damaged_bgm
export (AudioStream) var level_1_eroded_bgm
# Level 2
export (AudioStream) var level_2_solid_bgm
export (AudioStream) var level_2_damaged_bgm
export (AudioStream) var level_2_eroded_bgm
# Level 3
export (AudioStream) var level_3_solid_bgm
export (AudioStream) var level_3_damaged_bgm
export (AudioStream) var level_3_eroded_bgm

onready var solid_player = $BGM_1
onready var damaged_player = $BGM_2
onready var eroded_player = $BGM_3

onready var animation_player = $AnimationPlayer


func _ready():
	assign_audio_streams()
	
	animation_player.play("solid_fade_in")
	
	solid_player.play()
	damaged_player.play()
	eroded_player.play()


func assign_audio_streams():
	match level_id:
		0:
			solid_player.stream = main_menu_bgm
			damaged_player.stream = main_menu_bgm
			eroded_player.stream = main_menu_bgm
		1:
			solid_player.stream = level_1_solid_bgm
			damaged_player.stream = level_1_damaged_bgm
			eroded_player.stream = level_1_eroded_bgm
		2:
			solid_player.stream = level_2_solid_bgm
			damaged_player.stream = level_2_damaged_bgm
			eroded_player.stream = level_2_eroded_bgm
		3:
			solid_player.stream = level_3_solid_bgm
			damaged_player.stream = level_3_damaged_bgm
			eroded_player.stream = level_3_eroded_bgm

#func _input(event):
#	if event is InputEventKey:
#		match event.scancode:
#			KEY_0:
#				animation_player.play("solid")
#			KEY_1:
#				animation_player.play("solid_to_damaged")
#			KEY_2:
#				animation_player.play("damaged_to_eroded")
#			KEY_3:
#				animation_player.play("eroded_to_damaged")
#			KEY_4:
#				animation_player.play("damaged_to_solid")


func reset_playback():
	solid_player.seek(0)
	damaged_player.seek(0)
	eroded_player.seek(0)


func advance_level():
	set_level_id(level_id + 1)


func main_menu():
	set_level_id(0)


func set_level_id(value):
	# Loop around the main level themes
	if value > 3:
		value = 1
	
	level_id = value
	
	match current_state:
		0:
			animation_player.queue("solid_fade_out")
		1:
			animation_player.queue("damaged_fade_out")
		2:
			animation_player.queue("eroded_fade_out")
	
	yield(animation_player, "animation_finished")
	
	solid_player.stop()
	damaged_player.stop()
	eroded_player.stop()
	
	assign_audio_streams()
	reset_playback()
	
	emit_signal("bgm_changed")
	
	solid_player.play()
	damaged_player.play()
	eroded_player.play()
	
	animation_player.play("solid_fade_in")

