extends Spatial

export (bool) var is_closed = true
export (NodePath) var trigger_path = null

onready var animation_player = $AnimationPlayer

var trigger


func _ready():
	yield(owner, "ready")
	if is_closed:
		animation_player.play("default_closed")
	else:
		animation_player.play("default_open")
	
	#
	if trigger_path:
		trigger = get_node(trigger_path)
		trigger.connect("activated", self, "_open_door")
		trigger.connect("deactivated", self, "_close_door")


func _open_door():
	animation_player.play("open")
	yield(animation_player, "animation_finished")


func _close_door():
	# TODO - add dust particle effect when slamming door shut
	animation_player.play("close")
	yield(animation_player, "animation_finished")
