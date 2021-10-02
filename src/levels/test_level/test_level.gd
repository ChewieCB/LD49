extends Spatial

onready var fadeout = $GUI/Fadeout
onready var game_over = $GUI/GameOver
onready var player = $PlayerRig/Player
onready var pickups = $Pickups.get_children()



func _ready():
	player.death_state.connect("dead", game_over, "fade_in")
	fadeout.fade_in(0.8)
	yield(fadeout.animation_player, "animation_finished")
	
	#
	for _pickup in pickups:
		if not _pickup.is_connected(
			"pickup_collected", 
			player.durability_state_machine.get_child(0),
			"_increase_durability"
		):
			_pickup.connect(
				"pickup_collected", 
				player.durability_state_machine.get_child(0), 
				"_increase_durability"
			)
			

