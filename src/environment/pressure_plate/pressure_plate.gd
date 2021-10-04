extends StaticBody

signal activated
signal deactivated

# How heavy the player has to be to trigger the pressure plate:
# 2 = SOLID, 1 = DAMAGED, 0 = ERODED
export (int) var weight_required = 2
var is_activated = false

onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("default")


func activate():
	is_activated = true
	animation_player.play("activate")
	yield(animation_player, "animation_finished")
	emit_signal("activated")


func deactivate():
	is_activated = false
	animation_player.play("deactivate")
	yield(animation_player, "animation_finished")
	emit_signal("deactivated")


func _on_Area_body_entered(body):
	if body is PlayerController:
		if not is_activated and body.durability_parent.weight >= weight_required:
			activate()


func _on_Area_body_exited(body):
	pass
#	if body is PlayerController:
#		deactivate()
