extends Spatial

onready var mesh_glass = $Armature/Skeleton/player_mesh_glass
onready var mesh_normal = $Armature/Skeleton/player_mesh_normal
onready var mesh_eroded = $Armature/Skeleton/player_mesh_eroded
onready var meshes = [mesh_glass, mesh_normal, mesh_eroded]

enum States { IDLE, RUN, JUMP, DOUBLE_JUMP, CLIMB, DASH_AIM, DASH, DIE }

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback = animation_tree["parameters/playback"]


func _ready():
	yield(owner, "ready")
	
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("01_idle")
	
	# Start with normal mesh
	_switch_player_mesh(1)


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("01_idle")
		States.RUN:
			_playback.travel("02_running")
		States.JUMP:
			_playback.travel("03_jumping")
		States.DOUBLE_JUMP:
			_playback.travel("04_double_jumping")
		States.CLIMB:
			_playback.travel("05_climbing")
		States.DASH_AIM:
			_playback.travel("06_air_dash")
		States.DASH:
			_playback.travel("06_air_dash")
		States.DIE:
			# TODO - add ragdoll
			_playback.travel("t_pose")
		_:
			_playback.travel("t_pose")


func _switch_player_mesh(mesh_index):
	var new_mesh
	match mesh_index:
		0:
			new_mesh = mesh_glass
		1:
			new_mesh = mesh_normal
		2:
			new_mesh = mesh_eroded
	
	for _mesh in meshes:
		if _mesh == new_mesh:
			_mesh.visible = true
		else:
			_mesh.visible = false
	
	# TODO - add some sort of juice here, a particle effect or something
	pass

