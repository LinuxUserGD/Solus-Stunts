extends MeshInstance

func update():
	var tex = get_node("../Viewport").get_texture()
	get_material_override().albedo_texture = tex
