extends KinematicBody
class_name PlayerController

# FIXME - this is the hackiest hack ever, but it'll hold for the jam
#onready var fadeout = $"../../GUI/Fadeout"

onready var default_collider = $CollisionShape

# Climbing raycasts
onready var climbing_rays = $ClimbingRayCasts
onready var body_rays = $ClimbingRayCasts/BodyRays
onready var head_rays = $ClimbingRayCasts/HeadRays
onready var foot_ray = $ClimbingRayCasts/FootRayCast
#
export (Vector3) var climb_ray_pos_normal = Vector3(0, 3.3, 0)
export (Vector3) var climb_ray_pos_jump = Vector3(0, 4.8, 0)
export (Vector3) var climb_ray_pos_double_jump = Vector3(0, 7.3, 0)

# Triggerable raycast
onready var trigger_ray = $TriggerRaycast

#onready var skin = $Collision/LlamaSkin
onready var tween = $Tween

onready var camera_pivot = get_node("../CameraPivot")
onready var camera = get_node("../CameraPivot/Camera")
var goal_quaternion

onready var skin = $PlayerSkin

onready var state_machine = $StateMachine
onready var death_state = $StateMachine/Movement/Dead
var is_dead = false
var has_jumped = false
var has_dashed = false

onready var durability_state_machine = $DurabilityStateMachine
onready var durability_parent = $DurabilityStateMachine/DurabilityParent
onready var state_label = $StatusLabels
onready var movement_state = $StateMachine/Movement

const SNAP_DIRECTION = Vector3.DOWN
const SNAP_LENGTH = 32

# Audio
onready var audio_manager = $AudioManager


# UI
onready var ui = $GUI/PlayerUI
onready var pickup_counter = ui.get_node("MarginContainer/GridContainer/HBoxContainer/CenterContainer3/PickupCounter")
onready var reverse_pickup_counter = ui.get_node("MarginContainer/GridContainer/HBoxContainer/CenterContainer2/ReversePickupCounter")
#
onready var durability_ui = $DurabilityUI/Viewport/DurabilityMeter

var pickup_count =  0 setget set_pickup_counter
var reverse_pickup_count =  0 setget set_reverse_pickup_counter

var space_state
var debug_meshes = []


func _ready():
#	yield(fadeout.animation_player, "animation_finished")
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = true
	is_dead = false
	has_jumped = false
	has_dashed = false


func _process(_delta):
	pickup_count = pickup_counter.pickup_count
	reverse_pickup_count = reverse_pickup_counter.pickup_count


func _physics_process(_delta):
	space_state = get_world().direct_space_state


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


func set_pickup_counter(value):
	pickup_count = value
	pickup_counter.set_pickup_count(pickup_count)


func set_reverse_pickup_counter(value):
	reverse_pickup_count = value
	reverse_pickup_counter.set_pickup_count(reverse_pickup_count)


func _generate_ik_debug(debug_positions: Array, colour: Color = Color.red):
	# Get the scene root
	var root = get_tree().root.get_children()[0]
	
	# Create a debug sphere
	var debug_sphere = SphereMesh.new()
	debug_sphere.height = 0.25
	debug_sphere.radius = 0.125
	 # Bright red material (unshaded).
	var material = SpatialMaterial.new()
	material.albedo_color = colour
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

