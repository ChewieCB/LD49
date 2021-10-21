extends Spatial

signal climb_up
signal climb_across
signal climb_end

onready var skeleton = $Armature/Skeleton
onready var left_hand_attach = $Armature/Skeleton/LHBoneAttach
onready var left_hand_ray = $Armature/Skeleton/LHBoneAttach/LHRayCast
onready var right_hand_attach = $Armature/Skeleton/RHBoneAttach
onready var right_hand_ray = $Armature/Skeleton/RHBoneAttach/RHRayCast
#
onready var hand_rays = [left_hand_ray, right_hand_ray]

onready var mesh_high = $Armature/Skeleton/mesh_high
onready var mesh_medium = $Armature/Skeleton/mesh_medium
onready var mesh_low = $Armature/Skeleton/mesh_low
onready var meshes = [mesh_high, mesh_medium, mesh_low]

enum States { 
	IDLE, RUN, JUMP, DOUBLE_JUMP, FALL,
	LAND_SOFT, LAND_MEDIUM, LAND_HARD, 
	CLIMB, 
	DASH_AIM, DASH, 
	DIE 
}

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback = animation_tree["parameters/playback"]

var root_motion
var root_motion_velocity


func _ready():
	if owner:
		yield(owner, "ready")
	
	animation_player.play("t-pose")
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("t-pose")
	
	# Start with solid mesh
	_switch_player_mesh(0)


func _physics_process(delta):
	root_motion = animation_tree.get_root_motion_transform()
	root_motion_velocity = root_motion.origin / delta


func transition_to(state_id: int):
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.RUN:
			_playback.travel("running")
		States.JUMP:
			_playback.travel("falling")
		States.FALL:
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


#func _start_ragdoll():
#	$Armature/Skeleton.physical_bones_start_simulation()
#
#
#func _stop_ragdoll():
#	$Armature/Skeleton.physical_bones_stop_simulation()

func _climb_up():
	emit_signal("climb_up")


func _climb_across():
	emit_signal("climb_across")

