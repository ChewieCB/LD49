extends Spatial

onready var fadeout = $GUI/Fadeout
onready var game_over = $GUI/GameOver
onready var player = $PlayerRig/Player



func _ready():
	player.death_state.connect("dead", game_over, "fade_in")
	fadeout.fade_in(0.8)
	yield(fadeout.animation_player, "animation_finished")

