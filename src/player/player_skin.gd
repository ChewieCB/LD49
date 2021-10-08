extends Spatial

onready var mesh_glass = $Armature/Skeleton/player_mesh_glass
onready var mesh_normal = $Armature/Skeleton/player_mesh_normal
onready var mesh_eroded = $Armature/Skeleton/player_mesh_eroded
onready var meshes = [mesh_glass, mesh_normal, mesh_eroded]

enum States { IDLE, RUN, JUMP, DOUBLE_JUMP, DASH_AIM, DASH, DIE }

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback = animation_tree["parameters/playback"]


func _ready():
	yield(owner, "ready")
	
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("idle")
	
	# Start with normal mesh
	_switch_player_mesh(1)


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.RUN:
			_playback.travel("run")
		States.JUMP:
			_playback.travel("jump")
		States.DOUBLE_JUMP:
			_playback.travel("double_jump")
		States.DASH_AIM:
			_playback.travel("dash_aim")
		States.DASH:
			_playback.travel("dash")
		States.DIE:
			_playback.travel("die")
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

