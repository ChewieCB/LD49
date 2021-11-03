extends StaticBody

signal activated
signal deactivated

# How heavy the player has to be to trigger the pressure plate:
# 2 = SOLID, 1 = DAMAGED, 0 = ERODED
export (int) var weight_required = 2
var is_activated = false

const red_colour = "cf565b"
const blue_colour = "84b5ff"

onready var animation_player = $AnimationPlayer

onready var mesh_parent = $Meshes
onready var actived_mesh = $Meshes/pressure_plate_activated
onready var deactived_mesh = $Meshes/pressure_plate_deactivated

onready var mesh_lights = $Lights.get_children()


func _ready():
	animation_player.play("default")


func activate():
	is_activated = true
	# Change Lights
	for _light in mesh_lights:
		_light.light_color = Color(blue_colour)
	
	# Change mesh
	actived_mesh.visible = true
	deactived_mesh.visible = false
	
	animation_player.play("activate")
	yield(animation_player, "animation_finished")
	emit_signal("activated")


func deactivate():
	is_activated = false
	
	# Change Lights
	for _light in mesh_lights:
		_light.light_color = Color(red_colour)
	
	# Change mesh
	actived_mesh.visible = false
	deactived_mesh.visible = true
	
	animation_player.play("deactivate")
	yield(animation_player, "animation_finished")
	emit_signal("deactivated")


func _on_Area_body_entered(body):
	if body is PlayerController:
		if not is_activated and body.durability_parent.weight >= weight_required:
			activate()


func _on_Area_body_exited(_body):
	pass
#	if body is PlayerController:
#		deactivate()
