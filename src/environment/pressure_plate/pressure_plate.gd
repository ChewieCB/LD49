extends StaticBody

signal activated
signal deactivated

var is_activated = false

onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("default")


func activate():
	is_activated = true
	animation_player.play("activate")
	emit_signal("activated")


func deactivate():
	is_activated = false
	animation_player.play("deactivate")
	emit_signal("deactivated")


func _on_Area_body_entered(body):
	if body is PlayerController:
		if not is_activated:
			activate()


#func _on_Area_body_exited(body):
#	if body is PlayerController:
#		deactivate()
