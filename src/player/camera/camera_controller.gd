extends Spatial

export (NodePath) var camera_target

onready var current_target = get_node(camera_target)

onready var camera = $Camera
onready var far_camera_collider = $MaxRayCast
onready var near_camera_collider = $MaxRayCast
onready var camera_collision_sphere = $Camera/Area
onready var tween = $Tween

var is_using_controller = false

var is_aiming = false

var min_look_angle = 0.0
var max_look_angle = 75.0

var camera_rotation = Vector3.ZERO
var camera_lerp_goal = Vector3.ZERO


var mouse_delta = Vector2.ZERO

onready var actor = get_parent().get_node("Player")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.rotation_degrees.y = current_target.rotation_degrees.y


func _unhandled_input(event):
	# Get pitch and yaw values from relative mouse/joystick movement
	if event is InputEventMouseMotion:
		is_using_controller = false
		mouse_delta = event.relative
	elif event is InputEventJoypadMotion:
		is_using_controller = true


func _physics_process(_delta):
	if not current_target.is_dead:
		self.global_transform.origin = current_target.global_transform.origin
	
	if is_aiming:
		min_look_angle = -45.0
		max_look_angle = 90.0
	else:
		min_look_angle = 0.0
		max_look_angle = 75.0
	
	if far_camera_collider.is_colliding():
		if near_camera_collider.is_colliding():
			camera.translation = near_camera_collider.cast_to
		else:
			camera.global_transform.origin = far_camera_collider.get_collision_point()
	else:
		camera.translation = far_camera_collider.cast_to


func _process(delta):
	if GlobalFlags.CAMERA_CONTROLS_ACTIVE:
		#
		if is_using_controller:
			mouse_delta = Vector2(
				Input.get_action_strength("p1_camera_right") - Input.get_action_strength("p1_camera_left"),
				Input.get_action_strength("p1_camera_up") - Input.get_action_strength("p1_camera_down")
			) * 10
			
		# Camera inversions
		if not LocalSettings.CAMERA_INVERT_X:
			mouse_delta.x *= -1
		if LocalSettings.CAMERA_INVERT_Y:
			mouse_delta.y *= -1
		
		var yaw_dir = mouse_delta.x
		var pitch_dir = mouse_delta.y
		
		#
		var is_player_moving_camera = (mouse_delta != Vector2.ZERO)
	
		# Rotate the camera pivot accordingly
		camera_rotation = Vector3(0, yaw_dir, pitch_dir) * 10.0 * delta #LocalSettings.LOOK_SENSITIVITY
		rotation_degrees.y += camera_rotation.y
		if GlobalFlags.PLAYER_CONTROLS_ACTIVE:
			current_target.rotation.y = rotation.y

		rotation_degrees.z += camera_rotation.z
		rotation_degrees.z = clamp(rotation_degrees.z, min_look_angle, max_look_angle)
		
		mouse_delta = Vector2.ZERO


func rotate_camera(goal_point, time):
	# Get the current state of the camera rotation as a Quat
	var current_quaternion = self.global_transform.basis.get_rotation_quat()
	var goal_quaternion = goal_point.get_rotation_quat()
	var midpoint = current_quaternion.slerp(goal_quaternion, 1.0)
	
	# Tween Basis rotation
	tween.interpolate_property(
		self,
		"global_transform:basis",
		self.global_transform.basis,
		Basis(midpoint),
		time,
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	tween.start()

