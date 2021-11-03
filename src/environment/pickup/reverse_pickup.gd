extends Spatial
class_name ReversePickup

signal pickup_collected

onready var animation_player = $AnimationPlayer
onready var orb = $ReversePickup


func _ready():
	self.add_to_group("pickups")
	animation_player.play("float")


func _on_ReversePickup_body_entered(body):
	if body is PlayerController:
		emit_signal("pickup_collected")
		body.audio_manager.transition_to(body.audio_manager.States.COLLECTED, 2)
		animation_player.play("null")
		orb.queue_free()

