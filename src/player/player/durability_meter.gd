tool
extends Control

var durability = 100
var current_angle = -1.6

var min_angle = -1.6
var max_angle = 4.7

var color = Color.white

onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("default")


func _draw():
	draw_durability_meter(
		get_viewport_rect().end / 2,
		40.0,
		37,
		current_angle,
		color
	)


func draw_durability_meter(position, size, width, _current, ui_color):
	draw_arc(
		position, size, 4.7, min_angle, 800, Color(0, 0, 0, 0.5), width, true
	)
	draw_arc(
		position, size, 4.7, current_angle, 800, ui_color, width, true
	)


func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		durability += 1
	elif Input.is_action_pressed("ui_down"):
		durability -= 1
	
	durability = clamp(durability, 0, 100)
	
	var value = ((min_angle * -1) + max_angle) / 100
	current_angle = max_angle - (durability * value)
	
	update()

