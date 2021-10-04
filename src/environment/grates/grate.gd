tool
extends StaticBody


export (bool) var has_lock = true
export (bool) var has_frame = true

onready var frame = $Frame
onready var lock = $Lock
onready var bars = $GrateBars


func _ready():
	yield(owner, "ready")
	lock.visible = has_lock
	frame.visible = has_frame



