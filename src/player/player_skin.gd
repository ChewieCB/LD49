tool
extends Spatial

onready var mesh_high = $Armature/Skeleton/mesh_high
onready var mesh_medium = $Armature/Skeleton/mesh_medium
onready var mesh_low = $Armature/Skeleton/mesh_low
onready var meshes = [mesh_high, mesh_medium, mesh_low]

enum States { IDLE, RUN, JUMP, DOUBLE_JUMP, CLIMB, DASH_AIM, DASH, DIE }

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var transition_player: AnimationPlayer = $TransitionAnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback = animation_tree["parameters/playback"]


func _ready():
	if owner:
		yield(owner, "ready")
	
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("t-pose")
	
	# Start with normal mesh
	_switch_player_mesh(1)


func _input(event):
	if Input.is_key_pressed(KEY_0):
		transition_to(States.IDLE)
	elif Input.is_key_pressed(KEY_1):
		transition_to(States.RUN)


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.RUN:
			_playback.travel("running")
		States.JUMP:
			_playback.travel("jumping")
		States.DOUBLE_JUMP:
			pass
#			_playback.travel("04_double_jumping")
		States.CLIMB:
			_playback.travel("climbing")
		States.DASH_AIM:
			_playback.travel("air-dash-aim")
		States.DASH:
			_playback.travel("air-dash-mid")
		States.DIE:
			# TODO - add ragdoll
			_playback.travel("dying")
		_:
			_playback.travel("t-pose")


func _switch_player_mesh(mesh_index):
	var new_mesh
	match mesh_index:
		0:
			new_mesh = mesh_high
		1:
			new_mesh = mesh_medium
		2:
			new_mesh = mesh_low
	
	for _mesh in meshes:
		if _mesh == new_mesh:
			_mesh.visible = true
		else:
			_mesh.visible = false
	
	# TODO - add some sort of juice here, a particle effect or something
	pass

