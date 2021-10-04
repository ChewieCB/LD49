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
export (AudioStreamSample) var air_dash_sandy_sfx
export (AudioStreamSample) var decay_sfx
export (AudioStreamSample) var die_sfx
# Pickup SFX samples
export (AudioStreamSample) var collected_sfx
export (AudioStreamSample) var use_add_sfx
export (AudioStreamSample) var use_remove_sfx
export (AudioStreamSample) var empty_sfx

enum States { 
	# Null state to stop looping samples
	IDLE,
	# Player SFX States
	MOVE_SLOW, MOVE_MEDIUM, MOVE_FAST, JUMP, DOUBLE_JUMP, LAND, CLIMB, 
	AIR_DASH_AIM, AIR_DASH, AIR_DASH_SANDY, DECAY, DIE,
	# Powerup SFX States
	COLLECTED, USE_ADD, USE_REMOVE, EMPTY
	}

onready var player_audio = $PlayerAudio
onready var aux_audio = $AuxAudio
onready var powerup_audio = $PowerupAudio

onready var audio_player = player_audio


func play_audio(state, sfx_player=0):
	# Check which player we're using
	match sfx_player:
		0:
			audio_player = player_audio
		1:
			audio_player = aux_audio
		2:
			audio_player = powerup_audio
	
	# Match the state to the sample
	match state:
		States.IDLE:
			audio_player.stream = null
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
		States.AIR_DASH_SANDY:
			audio_player.stream = air_dash_sandy_sfx
		States.DECAY:
			audio_player.stream = decay_sfx
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


func transition_walking_sfx(speed):
	match speed:
		0:
			transition_to(States.MOVE_SLOW)
		1:
			transition_to(States.MOVE_MEDIUM)
		2:
			transition_to(States.MOVE_FAST)


func stop_audio():
	audio_player.stop()
	audio_player.stream = null


func transition_to(state, sfx_player=0):
	stop_audio()
	play_audio(state, sfx_player)
	emit_signal("transitioned", state)
