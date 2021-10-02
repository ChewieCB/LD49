extends Spatial

export (NodePath) var camera_target

onready var current_target = get_node(camera_target)

onready var camera = $Camera
onready var far_camera_collider = $MaxRayCast
onready var near_camera_collider = $MaxRayCast
onready var camera_collision_sphere = $Camera/Area
onready var tween = $Tween

var is_using_controller = false

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
		if not LocalSettings.CAMERA_INVERT_X:
			mouse_delta.x *= -1
		if not LocalSettings.CAMERA_INVERT_Y:
			mouse_delta.y *= -1
	elif event is InputEventJoypadMotion:
		is_using_controller = true


func _physics_process(_delta):
	self.global_transform.origin = current_target.global_transform.origin
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
		
		#
		var yaw_dir = mouse_delta.x
		var pitch_dir = mouse_delta.y
		
		#
		var is_player_moving_camera = (mouse_delta != Vector2.ZERO)
		
		# Let the player input override the charge cam tween when the tween
		# is still active but the player is not charging
		if is_player_moving_camera and tween.is_active() and not current_target.is_charging:
			tween.stop_all()
	
		# Rotate the camera pivot accordingly
		camera_rotation = Vector3(0, yaw_dir, pitch_dir) * LocalSettings.LOOK_SENSITIVITY * delta
		rotation_degrees.y += camera_rotation.y

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

