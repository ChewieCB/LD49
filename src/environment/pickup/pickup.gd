extends Area

signal pickup_collected


func _physics_process(delta):
	self.rotate_y(PI/32)


func _on_RepairPickup_body_entered(body):
	if body is PlayerController:
		emit_signal("pickup_collected")
		self.queue_free()

