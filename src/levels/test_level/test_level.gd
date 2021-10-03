extends Spatial

onready var fadeout = $GUI/Fadeout
onready var game_over = $GUI/GameOver
onready var player = $PlayerRig/Player
onready var pickups = $Pickups.get_children()
onready var reverse_pickups = $ReversePickups.get_children()



func _ready():
	player.death_state.connect("dead", game_over, "fade_in")
	fadeout.fade_in(0.8)
	yield(fadeout.animation_player, "animation_finished")
	
	#
	for _pickup in pickups:
		if not _pickup.is_connected(
			"pickup_collected",
			player.pickup_counter,
			"_increase_pickup_counter"
		):
			_pickup.connect(
				"pickup_collected",
				player.pickup_counter,
				"_increase_pickup_counter"
			)
	
	for _pickup in reverse_pickups:
		if not _pickup.is_connected(
			"pickup_collected",
			player.reverse_pickup_counter,
			"_increase_pickup_counter"
		):
			_pickup.connect(
				"pickup_collected",
				player.reverse_pickup_counter,
				"_increase_pickup_counter"
			)

