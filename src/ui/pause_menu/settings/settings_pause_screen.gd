extends Control

onready var settings_ui = $MainMargin/HBoxContainer/Elements/Buttons/HBoxContainer/SettingsUI
onready var buttons = [
	settings_ui.get_node("Display/Fullscreen/CheckBox"),
	settings_ui.get_node("Display/FOV/HSlider"),
	settings_ui.get_node("Controls/LookSensitivity/HSlider"),
	settings_ui.get_node("Controls/ControlMapping/Button"),
	settings_ui.get_node("Audio/SFXVolume/HSlider"),
	settings_ui.get_node("Audio/MusicVolume/HSlider"),
	settings_ui.get_node("Effects/ScreenShake/HSlider"),
	$MainMargin/HBoxContainer/Elements/Buttons/BackButton/Button
]


func _ready():
	yield(LocalSettings._ready(), "completed")
	buttons[0].pressed = LocalSettings.FULLSCREEN
	buttons[1].value = LocalSettings.FOV
	buttons[2].value = LocalSettings.LOOK_SENSITIVITY
	# TODO - control re-mapping
#	buttons[3].pressed = null
	buttons[4].value = LocalSettings.SFX_VOLUME
	buttons[5].value = LocalSettings.MUSIC_VOLUME
	buttons[6].value = LocalSettings.SCREEN_SHAKE
