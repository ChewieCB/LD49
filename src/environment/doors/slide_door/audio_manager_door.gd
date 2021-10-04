tool
extends Node

signal transitioned

export (AudioStreamSample) var door_open_sfx
export (AudioStreamSample) var door_close_sfx


enum States { 
	# Null state to stop looping samples
	IDLE,
	#
	OPEN, CLOSE
}

onready var close_player = $ClosePlayer
onready var hit_player = $HitPlayer
onready var rumble_player = $RumblePlayer
onready var open_player = $OpenPlayer

onready var audio_player = open_player


func _open():
	transition_to(States.OPEN)


func _close():
	transition_to(States.CLOSE)


func _hit():
	hit_player.play()


func _rumble():
	rumble_player.play()


func play_audio(state):
	# Match the state to the sample
	match state:
		States.IDLE:
			audio_player.stream = null
		States.OPEN:
			audio_player = open_player
			audio_player.stream = door_open_sfx
		States.CLOSE:
			audio_player = close_player
			audio_player.stream = door_close_sfx
	
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
