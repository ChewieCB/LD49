extends Spatial
# Controls the animation tree's transitions for this animated character
# it has a signal connected to the player state machine, and uses the resulting 
# state names to translate them into the states for the animation tree

#enum States { IDLE, MOVE, JUMP, DOUBLE_JUMP, CLIMB}

#onready var animation_player: AnimationPlayer = $AnimationPlayer
#onready var animation_tree: AnimationTree = $AnimationTree
#onready var _playback = animation_tree["parameters/playback"]

onready var solid_mesh = $Armature/Skeleton/SolidMesh
onready var damaged_mesh = $Armature/Skeleton/DamagedMesh
onready var eroded_mesh = $Armature/Skeleton/ErodedMesh

onready var meshes = [solid_mesh, damaged_mesh, eroded_mesh]


func switch_mesh(mesh_level):
	var new_mesh
	match mesh_level:
		0:
			new_mesh = solid_mesh
		1:
			new_mesh = damaged_mesh
		2:
			new_mesh = eroded_mesh
	
	for _mesh in meshes:
		if _mesh == new_mesh:
			_mesh.visible = true
		else:
			_mesh.visible = false

#
#func transition_to(state_id: int):
#	match state_id:
#		States.IDLE:
#			_playback.travel("Idle")
#		States.MOVE:
#			_playback.travel("Move")
#		States.JUMP:
#			_playback.travel("Jump")
#		States.DOUBLE_JUMP:
#			_playback.travel("DoubleJump")
#		States.CLIMB:
#			_playback.travel("Climb")
#		_:
#			_playback.travel("Idle")

