extends Camera

export var rotation_speed = 0.1


func _process(delta):
	self.global_rotate(Vector3.UP, PI/4 * delta * rotation_speed)
