extends Spatial
class_name Pickup

signal pickup_collected

onready var animation_player = $AnimationPlayer
onready var orb = $RepairPickup


func _ready():
	animation_player.play("float")


func _on_RepairPickup_body_entered(body):
	if body is PlayerController:
		emit_signal("pickup_collected")
		body.audio_manager.transition_to(body.audio_manager.States.COLLECTED)
		orb.queue_free()

