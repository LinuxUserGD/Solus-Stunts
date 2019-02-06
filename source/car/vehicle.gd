extends VehicleBody

const MAX_SPEED = 55
const STEER_SPEED = 1
const STEER_LIMIT = 0.4

slave var f = 0
slave var b = 0
slave var s_a = 0
slave var tr = Vector3()
slave var ro = Vector3()

export var force = 1500

var braking_force_mult = 4
var offset

var steer_angle = 0
var steer_target = 0
var predicted_steer = 0

var speed
var speed_int = 0
var speed_kph = 0

var forward_vec
var reverse

func _physics_process(delta):
	speed = get_linear_velocity().length()
	get_node("label/fps").set_text(str(Engine.get_frames_per_second()))
	get_node("label/v").set_text(str(round(speed*3.6)))
	
	if (speed > 35):
		STEER_LIMIT = 0.2
		STEER_SPEED = 0.5
	elif (speed > 28):
		STEER_LIMIT = 0.4
		STEER_SPEED = 0.5
	elif (speed > 15):
		STEER_LIMIT = 0.5
		STEER_SPEED = 0.5
	elif (speed > 5):
		STEER_LIMIT = 0.75
		STEER_SPEED = 0.5
	else:
		STEER_LIMIT = 1
		STEER_SPEED = 1
	
	if (is_network_master()):
		get_node("cambase/Camera").make_current()
		
		if Input.is_action_pressed("ui_left"):
			steer_target = STEER_LIMIT
		elif Input.is_action_pressed("ui_right"):
			steer_target = -STEER_LIMIT
		else:
			steer_target = 0
		
		if Input.is_action_pressed("ui_up"):
			if (speed < MAX_SPEED):
				set_engine_force(force)
			else:
				set_engine_force(0)
		else:
			if (speed > 3):
				set_engine_force(-force/4)
			else:
				set_engine_force(0)
		
		if Input.is_action_pressed("ui_down"):
			if (speed > 5):
				set_brake(1)
				set_engine_force(-force*braking_force_mult)
			else:
				set_brake(0.0)
				set_engine_force(-force)
			
		else:
			set_brake(0.0)
		
		rset("f", get_engine_force())
		rset("b", get_brake())
		rset("s_a", get_steering())
		
		rset("tr", get_translation())
		rset("ro", get_rotation())
		
	else:
		set_engine_force(f)
		set_brake(b)
		set_steering(s_a)
		
		set_translation(tr)
		set_rotation(ro)
		
	if (steer_target < steer_angle):
		steer_angle -= STEER_SPEED*delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += STEER_SPEED*delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	if (is_network_master()):
		set_steering(steer_angle)
	
	var forward_vec = get_global_transform().xform(Vector3(0, 1.5, 2))-get_global_transform().origin
	if (get_linear_velocity().dot(forward_vec) > 0):
		reverse = false
	else:
		reverse = true
		
func _ready():
	_physics_process(true)