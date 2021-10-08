extends Spatial

onready var fadeout = $"../GUI/Fadeout"
export (NodePath) var player_path
var player

export (String) var next_level_path

func _ready():
	if player_path:
		player = get_node(player_path)


func kill_player():
	if player:
		player.state_machine.transition_to("Movement/Dead")


func _on_Area_body_entered(body):
	if body is PlayerController:
		kill_player()
