extends Area
class_name Pickup

signal pickup_collected

onready var animation_player = $AnimationPlayer


func _ready():
	self.add_to_group("pickups")
	animation_player.play("float")


func _physics_process(delta):
	self.rotate_y(PI/32)


func _on_RepairPickup_body_entered(body):
	if body is PlayerController:
		emit_signal("pickup_collected")
		body.audio_manager.transition_to(body.audio_manager.States.COLLECTED)
		self.queue_free()

