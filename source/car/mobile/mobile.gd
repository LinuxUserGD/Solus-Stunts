extends Control

onready var l = $"/root/lobby"
func _ready():
	pass

func _on_left_pressed():
	if l.is_processing_input()==true:
		l.left()

func _on_right_pressed():
	if l.is_processing_input()==true:
		l.right()