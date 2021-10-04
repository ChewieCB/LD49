extends KinematicBody
class_name PlayerController

# FIXME - this is the hackiest hack ever, but it'll hold for the jam
onready var fadeout = $"../../GUI/Fadeout"

onready var default_collider = $CollisionShape

onready var debug_mesh = $DEBUG_MESH

# Climbing raycasts
onready var body_rays = $ClimbingRayCasts/BodyRays
onready var head_rays = $ClimbingRayCasts/HeadRays
onready var foot_ray = $ClimbingRayCasts/FootRayCast

# Triggerable raycast
onready var trigger_ray = $TriggerRaycast
#onready var slope_raycast = $SlopeRayCast
#onready var impassable_raycast = $Collision/ImpassableRayCast
#onready var knockback_raycasts = $Collision/KnockbackRayCasts.get_children()

#onready var skin = $Collision/LlamaSkin
onready var tween = $Tween

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

onready var solid_mesh = $DamageMeshes/Solid
onready var damaged_mesh = $DamageMeshes/Damaged
onready var eroded_mesh = $DamageMeshes/Eroded


func _ready():
	yield(fadeout.animation_player, "animation_finished")
	GlobalFlags.PLAYER_CONTROLS_ACTIVE = true
	GlobalFlags.CAMERA_CONTROLS_ACTIVE = true
	is_dead = false
	has_jumped = false
	has_dashed = false


func _process(_delta):
	pickup_count = pickup_counter.pickup_count
	reverse_pickup_count = reverse_pickup_counter.pickup_count


func switch_mesh(mesh_id):
	match mesh_id:
		0:
			solid_mesh.visible = true
			damaged_mesh.visible = false
			eroded_mesh.visible = false
		1:
			solid_mesh.visible = false
			damaged_mesh.visible = true
			eroded_mesh.visible = false
		2:
			solid_mesh.visible = false
			damaged_mesh.visible = false
			eroded_mesh.visible = true


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
