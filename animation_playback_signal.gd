extends AnimationNodeStateMachinePlayback

signal traveled_to(to_node)


func travel(to_node):
	#
	.travel(to_node)
	#
	emit_signal("traveled_to", to_node)

