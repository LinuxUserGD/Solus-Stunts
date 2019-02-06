extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func set_player_name(new_name):
	get_node("BODY/Viewport/Nametag/Label").set_text(new_name)
	get_node("BODY/MeshInstance").update()