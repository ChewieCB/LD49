extends Spatial

onready var mesh_high = $Armature/Skeleton/PlayerMeshSolid
onready var mesh_medium = $Armature/Skeleton/PlayerMeshNormal
onready var mesh_low = $Armature/Skeleton/PlayerMeshDamaged
onready var meshes = [mesh_high, mesh_medium, mesh_low]

enum States { 
	IDLE, RUN, JUMP, DOUBLE_JUMP, FALL,
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
	
	# Start with solid mesh
	_switch_player_mesh(0)


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.RUN:
			_playback.travel("running")
		States.JUMP:
			_playback.travel("fall")
		States.FALL:
			_playback.travel("fall")
		States.DOUBLE_JUMP:
			_playback.travel("double-jump")
		States.LAND_SOFT:
			_playback.travel("land-soft")
		States.LAND_MEDIUM:
			_playback.travel("land-medium")
		States.LAND_HARD:
			_playback.travel("land-hard")
		States.CLIMB:
			_playback.travel("climb")
		States.DASH_AIM:
			_playback.travel("air-dash-aim")
		States.DASH:
			_playback.travel("air-dash-start")
		States.DIE:
			# TODO - add ragdoll
			_playback.travel("dying")
		_:
			pass
#			_playback.travel("t-pose")


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

#func _start_ragdoll():
#	$Armature/Skeleton.physical_bones_start_simulation()
#
#
#func _stop_ragdoll():
#	$Armature/Skeleton.physical_bones_stop_simulation()


