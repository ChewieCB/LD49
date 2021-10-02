extends KinematicBody
class_name PlayerController

#onready var fadeout = $UI/Fadeout

onready var default_collider = $CollisionShape

onready var debug_mesh = $DEBUG_MESH

# Climbing raycasts
onready var body_rays = $ClimbingRayCasts/BodyRays
onready var head_rays = $ClimbingRayCasts/HeadRays
onready var foot_ray = $ClimbingRayCasts/FootRayCast
#onready var slope_raycast = $SlopeRayCast
#onready var impassable_raycast = $Collision/ImpassableRayCast
#onready var knockback_raycasts = $Collision/KnockbackRayCasts.get_children()

#onready var skin = $Collision/LlamaSkin
onready var tween = $Tween

onready var audio_player = $AudioPlayer

# Array of all things that should rotate
#onready var rotateable = [
#	collision,
#	default_collider,
##	slope_raycast,
##	impassable_raycast,
#]

onready var camera_pivot = get_node("../CameraPivot")
onready var camera = get_node("../CameraPivot/Camera")
var goal_quaternion

onready var state_machine = $StateMachine
onready var durability_state_machine = $DurabilityStateMachine
onready var state_label = $StatusLabels/Viewport/StateLabel
onready var movement_state = $StateMachine/Movement

const SNAP_DIRECTION = Vector3.DOWN
const SNAP_LENGTH = 32

var debug_trajectory_meshes = []


func can_mantle():
	var body_ray_count = 0
	for _ray in body_rays.get_children():
		if _ray.is_colliding():
			body_ray_count += 1
	if body_ray_count == 0:
		return false
	
	for _ray in head_rays.get_children():
		if _ray.is_colliding():
			return false
	
	return true


func generate_debug_trajectory(trajectory_points, size):
	if not GlobalFlags.SHOW_DEBUG_TRAJECTORIES:
		return
	
	clear_debug_trajectory()
	# Get scene root
	var scene_root = get_tree().root.get_children()[0]
	for _point in trajectory_points:
		# Create sphere with low detail of size.
		var sphere = SphereMesh.new()
		sphere.radial_segments = 8
		sphere.rings = 8
		sphere.radius = size
		sphere.height = size * 2
		# Bright red material (unshaded).
		var material = SpatialMaterial.new()
		material.albedo_color = Color(1, 0, 0)
		material.flags_unshaded = true
		sphere.surface_set_material(0, material)
		
		# Add to meshinstance in the right place.
		var node = MeshInstance.new()
		node.mesh = sphere
		if node.is_inside_tree():
			node.global_transform.origin = _point
		scene_root.add_child(node)
		debug_trajectory_meshes.append(node)


func clear_debug_trajectory():
	for mesh in debug_trajectory_meshes:
		mesh.queue_free()
	debug_trajectory_meshes = []

