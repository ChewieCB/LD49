extends Spatial

onready var fadeout = $"../GUI/Fadeout"
onready var player = $"../PlayerRig/Player"

export (String) var next_level_path


func kill_player():
	player.state_machine.transition_to("Movement/Dead")


func _on_Area_body_entered(body):
	if body is PlayerController:
		kill_player()
