extends Spatial

#onready var fadeout = $GUI/Fadeout
onready var game_over = $GUI/GameOver
onready var player = $PlayerRig/Player
onready var pickups = get_tree().get_nodes_in_group("pickups")


func _ready():
	yield(DynamicMusicManager.animation_player, "animation_finished")
	player.death_state.connect("dead", game_over, "fade_in")
#	fadeout.fade_in(0.5)
#	yield(fadeout.animation_player, "animation_finished")
	
	#
	for _pickup in pickups:
		if _pickup is Pickup:
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
		elif _pickup is ReversePickup:
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
