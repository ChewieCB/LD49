extends Spatial

onready var mesh_high = $Armature/Skeleton/mesh_high
onready var mesh_medium = $Armature/Skeleton/mesh_medium
onready var mesh_low = $Armature/Skeleton/mesh_low
onready var meshes = [mesh_high, mesh_medium, mesh_low]

enum States { 
	IDLE, RUN, JUMP, DOUBLE_JUMP,
	LAND_SOFT, LAND_MEDIUM, LAND_HARD, 
	CLIMB, 
	DASH_AIM, DASH, 
	DIE 
}

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var transition_player: AnimationPlayer = $TransitionAnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback = animation_tree["parameters/playback"]


func _ready():
	if owner:
		yield(owner, "ready")
	
	animation_player.play("t-pose")
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("t-pose")
	
	# Start with normal mesh
	_switch_player_mesh(1)


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.RUN:
			_playback.travel("running")
		States.JUMP:
			_playback.travel("falling")
		States.DOUBLE_JUMP:
			_playback.travel("double-jumping")
		States.LAND_SOFT:
			_playback.travel("land-soft")
		States.LAND_MEDIUM:
			_playback.travel("land-medium")
		States.LAND_HARD:
			_playback.travel("land-hard")
		States.CLIMB:
			_playback.travel("climbing")
		States.DASH_AIM:
			_playback.travel("air-dash-aim")
		States.DASH:
			_playback.travel("air-dash-start")
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

