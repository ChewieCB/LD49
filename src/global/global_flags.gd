extends Node

var PLAYER_CONTROLS_ACTIVE = true setget set_PLAYER_CONTROLS_ACTIVE
var CAMERA_CONTROLS_ACTIVE = true setget set_CAMERA_CONTROLS_ACTIVE

var SHOW_STATE_LABELS = true setget set_SHOW_STATE_LABELS
var SHOW_DEBUG_TRAJECTORIES = false
var DEBUG_POWERUPS = true


func set_CAMERA_CONTROLS_ACTIVE(value):
	CAMERA_CONTROLS_ACTIVE = value


func set_PLAYER_CONTROLS_ACTIVE(value):
	PLAYER_CONTROLS_ACTIVE = value


func set_SHOW_STATE_LABELS(value):
	SHOW_STATE_LABELS = value
