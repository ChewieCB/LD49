extends HSplitContainer

onready var icon = $CenterContainer/TextureRect
onready var label = $Label
var pickup_count = 0 setget set_pickup_count


func _increase_pickup_counter():
	set_pickup_count(pickup_count + 1)


func set_pickup_count(value):
	pickup_count = value
	label.text = " %s" % [pickup_count]

