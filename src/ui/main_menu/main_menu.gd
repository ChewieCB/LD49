extends Node

onready var audio_player = $AudioPlayer
onready var animation_player = $AnimationPlayer

export (NodePath) var game_start_path
onready var main_screen = $GUI/MainScreen
onready var settings_screen = $GUI/SettingsScreen
onready var credits_screen = $GUI/CreditsScreen

var current_menu setget set_current_menu
var current_element


func _ready():
	get_tree().paused = false
	
	animation_player.play("default")
	set_current_menu(main_screen)
	
# warning-ignore:return_value_discarded
	Input.connect("joy_connection_changed", self, "controller_ui_focus")


func _input(_event):
	if Input.is_action_just_released("ui_down") or \
	Input.is_action_just_released("ui_up"):
		# We only want this to grab focus on the FIRST pressing when 
		# no buttons have focus, so if any buttons currently have focus, exit.
		for _button in current_menu.buttons:
			if _button.has_focus():
				return
		
		# By default grab focus on the first button
		current_menu.buttons[0].grab_focus()
	else:
		current_element = current_menu.get_focus_owner()
		if current_element and current_element is HSlider:
			if Input.is_action_just_pressed("ui_left"):
				if current_element.value != current_element.min_value:
					current_element.value -= 1
				# FIXME - we want to be able to move to the back button from
				# the start/end of these sliders
#				elif current_element.focus_neighbor_left:
#					current_element.focus_previous.grab_focus()
			elif Input.is_action_just_pressed("ui_right"):
				if current_element.value != current_element.max_value:
					current_element.value += 1
				# FIXME - we want to be able to move to the back button from
				# the start/end of these sliders
#				elif current_element.focus_neighbor_right:
#					current_element.focus_next.grab_focus()



func controller_ui_focus(_device, connected):
	var has_focus = false
	var button_with_focus
	
	# Determine if we already have focus
	for _button in current_menu.buttons:
		if _button.has_focus():
			has_focus = true
			button_with_focus = _button
			break
	
	if connected and not has_focus:
		current_menu.buttons[0].grab_focus()
	elif not connected and has_focus:
		button_with_focus.release_focus()


func transition_to_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene(game_start_path)


func set_current_menu(menu_screen):
	if current_menu:
		# Remove focus from the old menu screen
		for _button in current_menu.buttons:
			_button.focus_mode = 0
	
	# Set the new menu screen
	current_menu = menu_screen
	
	# Exit if the screen is just a display
	if not "buttons" in current_menu:
		return
	
	# Bit of DRY here but it's a simple hack, make the focus mode of the first
	# element 2 so we can always grab it.
	current_menu.buttons[0].focus_mode = 2
	current_menu.buttons[0].grab_focus()
	
	# Add focus to the new menu screen
	for _button in current_menu.buttons:
		# Set all buttons to have an initial focus mode of FOCUS_ALL
		_button.focus_mode = 2
		# Connect the focus_enter signal for each button to the sfx player
		if not _button.is_connected("focus_entered", audio_player, "cursor"):
			_button.connect("focus_entered", audio_player, "cursor")
		
		# Connect audio signals for each button
		var _button_signal
		match _button.get_class():
			"HSlider":
				_button_signal = "value_changed"
				if not _button.is_connected(_button_signal, audio_player, "cursor"):
					_button.connect(_button_signal, audio_player, "cursor")
			_:
				_button_signal = "pressed"
				# If the button is the last one of the array it's either a quit
				# or a back button, so we want a different tone.
				var tone
				if _button == current_menu.buttons[current_menu.buttons.size() - 1]:
					tone = "cancel"
				else:
					tone = "confirm"
				if not _button.is_connected(_button_signal, audio_player, tone):
					_button.connect(_button_signal, audio_player, tone)
			
		

# MAIN SCREEN SIGNALS

func _on_PlayButton_pressed():
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	# Disable player input during transition
	set_process_input(false)
	
	animation_player.play("main_to_settings")
	yield(animation_player, "animation_finished")
	
	set_current_menu(settings_screen)
	
	# Re-enable player input
	set_process_input(true)


func _on_CreditsButton_pressed():
	# Disable player input during transition
	set_process_input(false)
	
	animation_player.play("main_to_credits")
	yield(animation_player, "animation_finished")
	
	set_current_menu(credits_screen)
	
	# Re-enable player input
	set_process_input(true)


func _on_QuitButton_pressed():
	get_tree().quit()


# OPTIONS SCREEN SIGNALS

func _on_Fullscreen_pressed():
	LocalSettings.set_FULLSCREEN(!LocalSettings.FULLSCREEN)


func _on_FOV_value_changed(value):
	LocalSettings.set_FOV(value)


func _on_LookSensitivity_value_changed(value):
	LocalSettings.set_LOOK_SENSITIVITY(value)


func _on_ControlMapping_pressed():
	# TODO - add control re-mapping
	pass 


func _on_SFXVolume_value_changed(value):
	LocalSettings.set_SFX_VOLUME(value)


func _on_MusicVolume_value_changed(value):
	LocalSettings.set_MUSIC_VOLUME(value)


func _on_ScreenShake_value_changed(value):
	LocalSettings.set_SCREEN_SHAKE(value)


func _on_SettingsBackButton_pressed():
	# Disable player input during transition
	set_process_input(false)
	
	animation_player.play("settings_to_main")
	yield(animation_player, "animation_finished")
	
	set_current_menu(main_screen)
	
	# Grab the settings button focus
	current_menu.buttons[1].grab_focus()
	
	# Re-enable player input
	set_process_input(true)


# CREDITS SCREEN SIGNALS

func _on_CreditsBackButton_pressed():
	# Disable player input during transition
	set_process_input(false)
	
	animation_player.play("credits_to_main")
	yield(animation_player, "animation_finished")
	
	set_current_menu(main_screen)
	
	# Grab the settings button focus
	current_menu.buttons[2].grab_focus()
	
	# Re-enable player input
	set_process_input(true)

