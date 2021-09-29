extends Control

onready var buttons = [
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Display/Fullscreen/CheckBox,
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Display/FOV/HSlider,
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Controls/LookSensitivity/HSlider,
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Controls/ControlMapping/Button,
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Audio/SFXVolume/HSlider,	
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Audio/MusicVolume/HSlider,
	$MainMargin/NinePatchRect/MarginContainer/HSplitContainer/VBoxContainer/Effects/ScreenShake/HSlider,
	$MainMargin/NinePatchRect/MarginContainer2/Back/Button
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
