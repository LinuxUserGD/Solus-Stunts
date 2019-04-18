
extends Spatial
var loadimg = preload("res://images/screen.jpg")
var track1 = preload("res://tracks/1/track1.jpg")
var track2 = preload("res://tracks/2/track2.jpg")
var track3 = preload("res://tracks/3/track3.jpg")
var begin = preload("res://images/car.jpg")
var carimg = preload("res://images/car.jpg")
var car
var car2
var car3
var car4
var car_num=1
var car_num2=1

var viewport = null

var img_s = carimg
var col_s = Color(1.0,1.0,1.0)
	
func loading(c):
	get_node("World/car_showcase/ground").angular_velocity.y = 0.5
	c.set_player_name("")
	set_wheel_pos(c)

func set_wheel_pos(c):
	var ypos= 0.2
	c.get_node("left_front").translation.y = ypos
	c.get_node("left_rear").translation.y = ypos
	c.get_node("right_front").translation.y = ypos
	c.get_node("right_rear").translation.y = ypos




func _ready():
	
	viewport = get_node("Viewport")
	
	init_connection()
	update_background(begin, null)
	remove_child(get_node("World/car_load1"))
	remove_child(get_node("World/car_load2"))
	set_process_input(true)
	set_background(load("res://hdri/cape_hill_2k.hdr"))
	car = load("res://car/1/car.tscn").instance()
	car2 = load("res://car/2/car2.tscn").instance()
	car3 = load("res://car/3/car3.tscn").instance()
	car4 = load("res://car/4/car4.tscn").instance()
	loading(get_node("car"))
	get_node("Viewport/mobile").set_process_input(false)


func init_connection():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")



func invalid_name():
	if (get_node("Viewport/connect/name").text == ""):
		get_node("Viewport/connect/error_label").text="Invalid name!"
		return true

func _on_host_pressed():
	if invalid_name():
		return
	get_node("Viewport/connect").hide()
	get_node("Viewport/players").show()
	get_node("Viewport/connect/error_label").text=""
	var player_name = get_node("Viewport/connect/name").text
	gamestate.host_game(player_name)
	refresh_lobby()

func _on_join_pressed():
	gamestate.car_num2 = car_num2
	if invalid_name():
		return
	var ip = get_node("Viewport/connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("Viewport/connect/error_label").text="Invalid IPv4 address!"
		return
	get_node("Viewport/connect/error_label").text=""
	get_node("Viewport/connect/host").disabled=true
	get_node("Viewport/connect/join").disabled=true
	var player_name = get_node("Viewport/connect/name").text
	gamestate.join_game(ip, player_name)

func _on_connection_success():
	get_node("Viewport/connect").hide()
	get_node("Viewport/players").show()

func _on_connection_failed():
	get_node("Viewport/connect/host").disabled=false
	get_node("Viewport/connect/join").disabled=false
	get_node("Viewport/connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	get_node("Viewport/connect").show()
	get_node("Viewport/players").hide()
	get_node("Viewport/connect/host").disabled=false
	get_node("Viewport/connect/join").disabled=false

func _on_game_error(errtxt):
	get_node("Viewport/connect/error").dialog_text=errtxt
	get_node("Viewport/connect/error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("Viewport/players/list").clear()
	get_node("Viewport/players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("Viewport/players/list").add_item(p)
	get_node("Viewport/players/start").disabled=not get_tree().is_network_server()


func _input(event):
	viewport.input(event)

	if Input.is_action_pressed("ui_right") and not event.is_echo():
		right()
	if Input.is_action_pressed("ui_left") and not event.is_echo():
		left()
	if event.is_action_pressed("toggle_menu"):
		var settings = get_node("Viewport/SettingsGUI")
		settings.visible = !settings.visible
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())

func right():
	remove_child(get_node("car"))
	if car_num <= 3:
		car_num += 1
	else:
		car_num = 1

	if car_num == 1:
		init(car)
	if car_num == 2:
		init(car2)
	if car_num == 3:
		init(car3)
	if car_num == 4:
		init(car4)

func init(c):
	c.gravity_scale = 0
	c.angular_velocity.y = 0.5
	get_node("World/car_showcase/ground").angular_velocity.y = 0.5
	c.set_player_name("")
	c.set_name("car")
	c.translation.y = 0.5
	c.translation.z = 0
	set_wheel_pos(c)
	add_child(c)
	if c.has_node("cambase/Camera/World"):
		c.get_node("cambase/Camera/World").queue_free()
	
func left():
	remove_child(get_node("car"))
	if car_num >= 2:
		car_num -= 1
	else:
		car_num = 4

	if car_num == 1:
		init(car)
	if car_num == 2:
		init(car2)
	if car_num == 3:
		init(car3)
	if car_num == 4:
		init(car4)

func _on_start_pressed():
	gamestate.car_num = car_num
	gamestate.begin_game()


func multiplayer_dialog():
	get_node("Viewport/connect").show()
	
func _on_settings_pressed():
	var settings = get_node("Viewport/SettingsGUI")
	settings.visible = !settings.visible


func _on_start_button_down():
	get_node("background/backbtn/background").texture = loadimg
	get_node("background/backbtn/background").z_index = 3

func _on_track1_mouse_entered():
	update_background(track1, null)


func _on_track2_mouse_entered():
	update_background(track2, null)


func _on_track3_mouse_entered():
	update_background(track3, null)

func update_background(img, col):
	var mesh = get_node("World/car_showcase/MeshInstance")
	var material = SpatialMaterial.new()
	material.flags_unshaded=true
	material.flags_transparent=true
	if img != null:
		img_s = img
		material.albedo_texture = img
	else:
		material.albedo_texture = img_s
	if col != null:
		col_s = col
		material.albedo_color = col
	else:
		material.albedo_color = col_s
	mesh.set_surface_material(0, material)

func _on_track1_pressed():
	gamestate.track=1
	multiplayer_dialog()


func _on_track2_pressed():
	gamestate.track=2
	multiplayer_dialog()


func _on_track3_pressed():
	gamestate.track=3
	multiplayer_dialog()

func _on_track4_pressed():
	gamestate.track=4
	multiplayer_dialog()


func _on_track5_pressed():
	gamestate.track=5
	multiplayer_dialog()

func set_background(background):
	$"/root/lobby/WorldEnvironment".environment.background_sky.panorama = background

func _on_playbtn_pressed():
	get_tree().get_root().get_node("lobby/Viewport/play").hide()
	get_tree().get_root().get_node("lobby/Viewport/UI").show()
