tool
extends Node

signal transitioned

export (AudioStreamSample) var activate_sfx
export (AudioStreamSample) var deactivate_sfx


enum States { 
	# Null state to stop looping samples
	IDLE,
	#
	ACTIVATE, DEACTIVATE
}

onready var audio_player = $AudioPlayer


func _activate():
	transition_to(States.ACTIVATE)


func _deactivate():
	transition_to(States.DEACTIVATE)


func play_audio(state):
	# Match the state to the sample
	match state:
		States.IDLE:
			audio_player.stream = null
		States.ACTIVATE:
			audio_player.stream = activate_sfx
		States.DEACTIVATE:
			audio_player.stream = deactivate_sfx
	
	# Play the audio
	if audio_player.stream:
		audio_player.play()


func stop_audio():
	audio_player.stop()
	audio_player.stream = null


func transition_to(state):
	stop_audio()
	play_audio(state)
	emit_signal("transitioned", state)
