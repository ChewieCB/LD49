extends Spatial

var movement_state = "MOVEMENT TEMP"
var durability_state = "DURABILITY TEMP"

func _ready():
	self.visible = GlobalFlags.SHOW_STATE_LABELS


func _process(_delta):
	$Viewport/StateLabel.text = "%s\n%s" % [movement_state, durability_state]

