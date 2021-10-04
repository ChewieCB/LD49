extends Node

signal transitioned

# Player SFX samples
export (AudioStreamSample) var move_slow_sfx
export (AudioStreamSample) var move_medium_sfx
export (AudioStreamSample) var move_fast_sfx
export (AudioStreamSample) var jump_sfx
export (AudioStreamSample) var double_jump_sfx
export (AudioStreamSample) var land_sfx
export (AudioStreamSample) var climb_sfx
export (AudioStreamSample) var air_dash_aim_sfx
export (AudioStreamSample) var air_dash_sfx
export (AudioStreamSample) var die_sfx
# Pickup SFX samples
export (AudioStreamSample) var collected_sfx
export (AudioStreamSample) var use_add_sfx
export (AudioStreamSample) var use_remove_sfx
export (AudioStreamSample) var empty_sfx

enum States { 
	# Player SFX States
	MOVE_SLOW, MOVE_MEDIUM, MOVE_FAST, JUMP, DOUBLE_JUMP, LAND, CLIMB, 
	AIR_DASH_AIM, AIR_DASH, DIE,
	# Powerup SFX States
	COLLECTED, USE_ADD, USE_REMOVE, EMPTY
	}

onready var player_audio = $PlayerAudio
onready var powerup_audio = $PowerupAudio
var audio_player = null


func play_audio(state, is_player_sfx=true):
	# Check which player we're using
	match is_player_sfx:
		true:
			audio_player = player_audio
		false:
			audio_player = powerup_audio
	
	# Match the state to the sample
	match state:
		States.MOVE_SLOW:
			audio_player.stream = move_slow_sfx
		States.MOVE_MEDIUM:
			audio_player.stream = move_medium_sfx
		States.MOVE_FAST:
			audio_player.stream = move_fast_sfx
		States.JUMP:
			audio_player.stream = jump_sfx
		States.DOUBLE_JUMP:
			audio_player.stream = double_jump_sfx
		States.LAND:
			audio_player.stream = land_sfx
		States.CLIMB:
			audio_player.stream = climb_sfx
		States.AIR_DASH_AIM:
			audio_player.stream = air_dash_aim_sfx
		States.AIR_DASH:
			audio_player.stream = air_dash_sfx
		States.DIE:
			audio_player.stream = die_sfx
		
		# Powerups
		States.COLLECTED:
			audio_player.stream = collected_sfx
		States.USE_ADD:
			audio_player.stream = use_add_sfx
		States.USE_REMOVE:
			audio_player.stream = use_remove_sfx
		States.EMPTY:
			audio_player.stream = empty_sfx
	
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
