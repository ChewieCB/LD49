extends AnimationTree

signal advanced_node

func _ready():
	# Load the animation tree
	var playback = load("res://src/player/meshes/v2/AnimTree.tres")
	
	# Extend the base travel method to emit a signal for callbacks 


func advance(delta):
	# Emit a signal we can use for transition animation callbacks
	emit_signal("advanced_node")
	# Call the original advance method
	.advance(delta)
