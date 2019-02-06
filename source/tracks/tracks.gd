extends Control
var track1 = preload("res://tracks/track1.jpg")
var track2 = preload("res://tracks/track2.jpg")
var track3 = preload("res://tracks/track3.jpg")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_track1_mouse_entered():
	get_node("background/backbtn/background").texture = track1


func _on_track2_mouse_entered():
	get_node("background/backbtn/background").texture = track2


func _on_track3_mouse_entered():
	get_node("background/backbtn/background").texture = track3


func _on_track1_focus_entered():
	pass # replace with function body
