tool
extends Spatial

export (int, 0, 5) var model_index setget set_model_index

# Simple
onready var mesh_flat_01 = $brick_flat_01
onready var mesh_flat_02 = $brick_flat_02
onready var mesh_flat_03 = $brick_flat_03
# Ornate
onready var mesh_ornate_01 = $brick_ornament_1
onready var mesh_ornate_02 = $brick_ornament_2
onready var mesh_ornate_03 = $brick_ornament_3

onready var mesh_options = [
	mesh_flat_01, mesh_flat_02, mesh_flat_03,
	mesh_ornate_01, mesh_ornate_02, mesh_ornate_03
]


func _ready():
	yield(owner, "ready")


func set_model_index(value: int):
	model_index = value
	
	if not mesh_options:
		return
	
	var new_mesh = mesh_options[model_index]
	
	for _mesh in mesh_options:
		if _mesh == new_mesh:
			_mesh.visible = true
			continue
		_mesh.visible = false
	
	

