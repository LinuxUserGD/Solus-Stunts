extends VehicleBody

var MAX_SPEED = 50
var STEER_SPEED = 1
var STEER_LIMIT = 0.4

var viewport = null

puppet var f = 0
puppet var b = 0
puppet var s_a = 0
puppet var tr = Vector3()
puppet var ro = Vector3()

export var force = 1500
var braking_force_mult = 4
var steer_angle = 0
var steer_target = 0
var speed 
var previous
var reverse
var time = 0
var loop_1 = load("res://assets/sound/loop_1.wav")
var loop_2 = load("res://assets/sound/loop_2.wav")
var loop_3 = load("res://assets/sound/loop_3.wav")
var loop_4 = load("res://assets/sound/loop_4.wav")
var loop_5 = load("res://assets/sound/loop_5.wav")
func _physics_process(_delta):
	if (is_network_master()):
		time += _delta
		speed = get_linear_velocity().length()
		if (speed > 35):
			if previous != 5:
				get_node("AudioStreamPlayer").stream = loop_5
				get_node("AudioStreamPlayer").play()
			previous = 5
			STEER_LIMIT = 0.2
			STEER_SPEED = 0.5
		elif (speed > 28):
			if previous != 4:
				get_node("AudioStreamPlayer").stream = loop_4
				get_node("AudioStreamPlayer").play()
			previous = 4
			STEER_LIMIT = 0.4
			STEER_SPEED = 0.5
		elif (speed > 15):
			if previous != 3:
				get_node("AudioStreamPlayer").stream = loop_3
				get_node("AudioStreamPlayer").play()
			previous = 3
			STEER_LIMIT = 0.5
			STEER_SPEED = 0.5
		elif (speed > 5):
			if previous != 2:
				get_node("AudioStreamPlayer").stream = loop_2
				get_node("AudioStreamPlayer").play()
			previous = 2
			STEER_LIMIT = 0.75
			STEER_SPEED = 0.5
		else:
			if previous != 1:
				get_node("AudioStreamPlayer").stream = loop_1
				get_node("AudioStreamPlayer").play()
			previous = 1
			STEER_LIMIT = 1
			STEER_SPEED = 1
		#get_node("cambase/Player/CenterViewport/Camera").make_current()
		get_node("info/fps").set_text(str(Engine.get_frames_per_second()) + " fps")
		get_node("info/v").set_text(str(round(speed*3.6)) + " km/h")
		var minutes = int(time/60)
		var seconds = int(time) - minutes * 60
		if minutes == 0:
			get_node("info/time").set_text(str(seconds) + "s")
		else:
			get_node("info/time").set_text(str(minutes) + "m " + str(seconds) + "s")
		
		if Input.is_action_pressed("ui_left") or get_node("Viewport2/mobile/steering/left").is_pressed():
			steer_target = STEER_LIMIT
		elif Input.is_action_pressed("ui_right") or get_node("Viewport2/mobile/steering/right").is_pressed():
			steer_target = -STEER_LIMIT
		else:
			steer_target = 0
		
		if Input.is_action_pressed("ui_up") or get_node("Viewport2/mobile/speed/gas").is_pressed():
			if (speed < MAX_SPEED):
				set_engine_force(force)
			else:
				set_engine_force(0)
		else:
			if (speed > 3):
				set_engine_force(-force/4)
			else:
				set_engine_force(0)
		
		if Input.is_action_pressed("ui_down") or get_node("Viewport2/mobile/speed/brake").is_pressed():
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
		steer_angle -= STEER_SPEED*_delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += STEER_SPEED*_delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	if (is_network_master()):
		set_steering(steer_angle)
	
	var forward_vec = -get_global_transform().origin
	if (get_linear_velocity().dot(forward_vec) > 0):
		reverse = false
	else:
		reverse = true

	
func set_player_name(new_name):
	get_node("Viewport/Nametag/Label").set_text(new_name)
	update()

func update():
	var tex = get_node("Viewport").get_texture()
	var mesh = get_node("MeshInstance")
	var material = SpatialMaterial.new()
	material.flags_unshaded=true
	material.flags_transparent=true
	mesh.set_surface_material(0, material)
	mesh.get_surface_material(0).albedo_texture = tex

func _input(event):
	viewport.input(event)

func _ready():
	viewport = get_node("Viewport2")
	set_physics_process(true)
	set_process_input(true)
	if name=="car" or name=="car_load1" or name=="car_load2":
		set_physics_process(false)


func _on_settings_pressed():
	if has_node("/root/lobby/Viewport/SettingsGUI"):
		var settings = get_node("/root/lobby/Viewport/SettingsGUI")
		settings.visible = !settings.visible
	else:
		var settings = get_node("/root/lobby/world/vehicles/" + str(get_tree().get_network_unique_id()) + "/Viewport2/SettingsGUI")
		settings.visible = !settings.visible
