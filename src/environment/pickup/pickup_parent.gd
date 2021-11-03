extends Spatial
class_name Pickup

signal pickup_collected

onready var animation_player = $AnimationPlayer
onready var orb = $RepairPickup


func _ready():
	self.add_to_group("Pickups")
	animation_player.play("float")


func _on_RepairPickup_body_entered(body):
	if body is PlayerController:
		emit_signal("pickup_collected")
		body.audio_manager.transition_to(body.audio_manager.States.COLLECTED, 1)
		animation_player.play("null")
		orb.queue_free()

