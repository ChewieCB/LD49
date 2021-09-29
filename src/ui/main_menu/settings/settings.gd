extends Node

signal FOV_CHANGED
signal LOOK_SENSITIVITY_CHANGED
signal SFX_VOLUME_CHANGED
signal MUSIC_VOLUME_CHANGED
signal SCREEN_SHAKE_CHANGED

var FULLSCREEN = true setget set_FULLSCREEN
var SCREEN_SIZE = Vector2(1920, 1080) setget set_SCREEN_SIZE
var FOV = 90 setget set_FOV
var LOOK_SENSITIVITY = 15 setget set_LOOK_SENSITIVITY
var SFX_VOLUME = 10 setget set_SFX_VOLUME
var MUSIC_VOLUME = 10 setget set_MUSIC_VOLUME
var SCREEN_SHAKE = 10 setget set_SCREEN_SHAKE

var config_file = "res://src/main_menu/settings.cfg"


func _ready():
	yield(read_local_settings(), "completed")
	
	var root = get_tree().get_root()
	if not root.is_connected("size_changed", self, "update_screen_size"):
		root.connect("size_changed", self, "update_screen_size")


func read_local_settings():
	# Read any pre-set settings from a JSON file.
	var file = File.new()
	if file.file_exists(config_file):
		file.open(config_file, File.READ)
		set_FULLSCREEN(file.get_var())
		set_SCREEN_SIZE(file.get_var())
		set_FOV(file.get_var())
		set_LOOK_SENSITIVITY(file.get_var())
		set_SFX_VOLUME(file.get_var())
		set_MUSIC_VOLUME(file.get_var())
		set_SCREEN_SHAKE(file.get_var())
	else:
		print("No config file found.")
	
	yield(get_tree(), "idle_frame")


func write_local_settings():
	# Write the settings here to a local JSON file so we can load them
	# when the game is closed and re-opened.
	var file = File.new()
	file.open(config_file, File.WRITE)
	
	file.store_var(FULLSCREEN)
	file.store_var(SCREEN_SIZE)
	file.store_var(FOV)
	file.store_var(LOOK_SENSITIVITY)
	file.store_var(SFX_VOLUME)
	file.store_var(MUSIC_VOLUME)
	file.store_var(SCREEN_SHAKE)
	
	file.close()


func update_screen_size():
	set_SCREEN_SIZE(get_viewport().size)


func set_FULLSCREEN(value):
	FULLSCREEN = value
	OS.window_fullscreen = FULLSCREEN
	write_local_settings()


func set_SCREEN_SIZE(value):
	SCREEN_SIZE = value
	OS.set_window_size(SCREEN_SIZE)
	write_local_settings()


func set_FOV(value):
	FOV = value
	emit_signal("FOV_CHANGED")
	write_local_settings()


func set_LOOK_SENSITIVITY(value):
	LOOK_SENSITIVITY = value
	emit_signal("LOOK_SENSITIVITY_CHANGED")
	write_local_settings()


func set_SFX_VOLUME(value):
	SFX_VOLUME = value
	emit_signal("SFX_VOLUME_CHANGED")
	write_local_settings()


func set_MUSIC_VOLUME(value):
	MUSIC_VOLUME = value
	emit_signal("MUSIC_VOLUME_CHANGED")
	write_local_settings()


func set_SCREEN_SHAKE(value):
	SCREEN_SHAKE = value
	emit_signal("SCREEN_SHAKE_CHANGED")
	write_local_settings()
