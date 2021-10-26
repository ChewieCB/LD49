extends Spatial

onready var mesh_high = $Armature/Skeleton/PlayerMeshSolid
onready var mesh_medium = $Armature/Skeleton/PlayerMeshNormal
onready var mesh_low = $Armature/Skeleton/PlayerMeshDamaged
onready var meshes = [mesh_high, mesh_medium, mesh_low]

# IK nodes
onready var skeleton = $Armature/Skeleton

onready var left_hand_ik = $Armature/Skeleton/LeftHandIK
onready var right_hand_ik = $Armature/Skeleton/RightHandIK
onready var left_hand_ik_target = $LeftHandIKTarget
onready var right_hand_ik_target = $RightHandIKTarget

onready var left_hand_attach = $Armature/Skeleton/LeftHandAttach
onready var right_hand_attach = $Armature/Skeleton/RightHandAttach
onready var left_hand_ray = $LeftHandRayCast
onready var right_hand_ray = $RightHandRayCast

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

var hand_ik_active = false
var cached_intersection_point_left
var cached_intersection_point_right

var climbing_mesh
var high_vert = Vector3.ZERO

var debug_meshes = []


func _ready():
	if owner:
		yield(owner, "ready")
	
	animation_player.play("t-pose")
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	_playback.start("t-pose")
	
	# Start with solid mesh
	_switch_player_mesh(0)


func _physics_process(_delta):
#	$Armature/Skeleton/LeftHandAttach.rotation_degrees = Vector3.ZERO
#	$Armature/Skeleton/RightHandAttach.rotation_degrees = Vector3.ZERO
#	left_hand_ray.transform.basis = Basis.IDENTITY
#	right_hand_ray.transform.basis = Basis.IDENTITY
	left_hand_ray.transform.origin = left_hand_attach.transform.origin
	right_hand_ray.transform.origin = right_hand_attach.transform.origin
	
	if hand_ik_active:
		get_hand_positions()


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


func get_hand_positions():
	# Cast a ray out from each hand in the direction of the climb, finding a
	# point on the climable mesh's surface
	var intersection_point_left = to_local(cached_intersection_point_left)
	var intersection_point_right = to_local(cached_intersection_point_right)
	
	# Find the edge to place the vertical positions
	if climbing_mesh:
		var mesh_aabb = climbing_mesh.get_aabb()
		# Find the vertices of the mesh
		high_vert = mesh_aabb.size

		intersection_point_left.y = to_local(high_vert).y
		intersection_point_right.y = to_local(high_vert).y
	
	# Move the IK targets
	left_hand_ik_target.transform.origin = intersection_point_left
	right_hand_ik_target.transform.origin = intersection_point_right


func _start_hand_ik():
	# TODO - set IK target to wall
	climbing_mesh = left_hand_ray.get_collider()
	climbing_mesh = right_hand_ray.get_collider()
	# Store the initial collision point (a GLOBAL position) to reference later
	# so we can have a fixed point relative to the scene.
	cached_intersection_point_left = left_hand_ray.get_collision_point()
	cached_intersection_point_right = right_hand_ray.get_collision_point()
	hand_ik_active = true
	
	# DEBUG - draw sphere meshes here to show the climb point
	var global_debug_pos = [
		Vector3(
			cached_intersection_point_left.x,
			high_vert.y,
			cached_intersection_point_left.z
		),
		Vector3(
			cached_intersection_point_right.x,
			high_vert.y,
			cached_intersection_point_right.z
		)
	]
	_generate_ik_debug(global_debug_pos)
	
	left_hand_ik.start()
	right_hand_ik.start()


func _stop_hand_ik():
	hand_ik_active = false
	left_hand_ik.stop()
	right_hand_ik.stop()
	
	# Remove any debug meshes
	_clear_ik_debug()
	
	# Clear overrides to reset to animation rest poses
	skeleton.clear_bones_global_pose_override()


func _generate_ik_debug(debug_positions: Array):
	# Get the scene root
	var root = get_tree().root.get_children()[0]
	
	# Create a debug sphere
	var debug_sphere = SphereMesh.new()
	debug_sphere.height = 1
	debug_sphere.radius = 0.5
	 # Bright red material (unshaded).
	var material = SpatialMaterial.new()
	material.albedo_color = Color(1, 0, 0)
	material.flags_unshaded = true
	debug_sphere.surface_set_material(0, material)
	
	# Generate a mesh for each hand hold point in the array
	for position in debug_positions:
		var debug_mesh = MeshInstance.new()
		debug_mesh.mesh = debug_sphere
		debug_mesh.global_transform.origin = position
		
		root.add_child(debug_mesh)
		debug_meshes.append(debug_mesh)


func _clear_ik_debug():
	var root = get_tree().root.get_children()[0]
	
	for mesh in debug_meshes:
		mesh.queue_free()
		root.remove_child(mesh)
		debug_meshes.erase(mesh)
