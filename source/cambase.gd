extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("screen_resized",self,"screen_resized")
	screen_resized()
	pass # Replace with function body.

func screen_resized():
	$"center/CenterViewport".size = get_viewport().size
	$"left/LeftViewport".size = get_viewport().size/2
	$"right/RightViewport".size = get_viewport().size/2
