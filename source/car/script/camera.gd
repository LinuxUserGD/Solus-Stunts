extends Spatial

var collision_exception = []
export var min_distance = 0.5
export var max_distance = 4.0
export var angle_v_adjust = 0.0
var max_height = 2.0
var min_height = 0

var debug
var origin
var target_orig

func _physics_process(_delta):
	if (not debug):
		
		var target = get_parent().get_global_transform().origin
		var pos = get_global_transform().origin
		var up = Vector3(0, 1, 0)
		
		var delta = pos - target
		if (delta.length() < min_distance):
			delta = delta.normalized()*min_distance
		elif (delta.length() > max_distance):
			delta = delta.normalized()*max_distance
		
		if ( delta.y > max_height):
			delta.y = max_height
		if ( delta.y < min_height):
			delta.y = min_height
		
		pos = target + delta
		if pos != target:
			look_at_from_position(pos, target, up)
			if has_node("/root/lobby/world/vehicles/" + str(gamestate.car_id)):
				var car = get_node("/root/lobby/world/vehicles/" + str(gamestate.car_id))
				car.get_node("left").look_at_from_position(pos, target, up)
				car.get_node("right").look_at_from_position(pos, target, up)
		
		var t = get_transform()
		t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust))*t.basis
		set_transform(t)
		if has_node("/root/lobby/world/vehicles/" + str(gamestate.car_id)):
			var car = get_node("/root/lobby/world/vehicles/" + str(gamestate.car_id))
			car.get_node("left").translation.x -= gamestate.x
			car.get_node("right").translation.x += gamestate.x
			
	else:
		var target = get_parent().get_global_transform().origin
		var delta = target - target_orig
		
		set_translation(origin+Vector3(0, 50, -origin.z)+delta)
		set_rotation_degrees(Vector3(-90, 0, 180))
		if has_node("/root/lobby/world/vehicles/" + str(gamestate.car_id)):
			var car = get_node("/root/lobby/world/vehicles/" + str(gamestate.car_id))
			car.get_node("left").set_translation(origin+Vector3(0, 50, -origin.z)+delta)
			car.get_node("right").set_translation(origin+Vector3(0, 50, -origin.z)+delta)
			car.get_node("left").set_rotation_degrees(Vector3(-90, 0, 180))
			car.get_node("right").set_rotation_degrees(Vector3(-90, 0, 180))

func set_debug(val):
	debug = val

func _ready():
	origin = get_global_transform().origin
	target_orig = get_parent().get_global_transform().origin
	var node = self
	while(node):
		if (node is RigidBody):
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	set_as_toplevel(true)
