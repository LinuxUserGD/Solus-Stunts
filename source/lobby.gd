extends WorldEnvironment
var track1 = preload("res://tracks/1/track1.jpg")
var track2 = preload("res://tracks/2/track2.jpg")
var track3 = preload("res://tracks/3/track3.jpg")
var carimg = preload("res://images/car.jpg")
var car
var car2
var car3
var car4
var track = 0
var car_num=1

var img_s = carimg
var col_s = Color(1.0,1.0,1.0)
func _ready():
	set_background(load("res://hdri/cape_hill_2k.hdr"))
	car = load("res://car/1/car.tscn").instance()
	car2 = load("res://car/2/car2.tscn").instance()
	car3 = load("res://car/3/car3.tscn").instance()
	car4 = load("res://car/4/car4.tscn").instance()
	loading(get_node("car"))
	set_process_input(false)
	get_node("mobile").set_process_input(false)
func loading(c):
	get_node("car_showcase/ground").angular_velocity.y = 0.5
	c.set_player_name("")
	set_wheel_pos(c)

func init_connection():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")

func init(c):
	c.gravity_scale = 0
	c.angular_velocity.y = 0.5
	get_node("car_showcase/ground").angular_velocity.y = 0.5
	c.set_player_name("")
	c.set_name("car")
	c.translation.y = 0.5
	c.translation.z = 0
	set_wheel_pos(c)
	add_child(c)

func set_wheel_pos(c):
	var ypos= 0.2
	c.get_node("left_front").translation.y = ypos
	c.get_node("left_rear").translation.y = ypos
	c.get_node("right_front").translation.y = ypos
	c.get_node("right_rear").translation.y = ypos

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

func invalid_name():
	if (get_node("mobile/connect/name").text == ""):
		get_node("mobile/connect/error_label").text="Invalid name!"
		return true

func _on_host_pressed():
	if invalid_name():
		return
	get_node("mobile/connect").hide()
	get_node("mobile/players").show()
	get_node("mobile/connect/error_label").text=""
	var player_name = get_node("mobile/connect/name").text
	gamestate.host_game(player_name)
	refresh_lobby()

func _on_connection_success():
	get_node("mobile/connect").hide()
	get_node("mobile/players").show()

func _on_connection_failed():
	get_node("mobile/connect/host").disabled=false
	get_node("mobile/connect/join").disabled=false
	get_node("mobile/connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	get_node("mobile").show()
	get_node("mobile/connect").show()
	get_node("mobile/players").hide()
	get_node("mobile/connect/host").disabled=false
	get_node("mobile/connect/join").disabled

func _on_game_error(errtxt):
	get_node("mobile/connect/error").dialog_text=errtxt
	get_node("mobile/connect/error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("mobile/players/list").clear()
	get_node("mobile/players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("mobile/players/list").add_item(p)
	get_node("mobile/players/start").disabled=not get_tree().is_network_server()

func _on_join_pressed():
	if invalid_name():
		return
	var ip = get_node("mobile/connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("mobile/connect/error_label").text="Invalid IPv4 address!"
		return
	get_node("mobile/connect/error_label").text=""
	get_node("mobile/connect/host").disabled=true
	get_node("mobile/connect/join").disabled=true
	var player_name = get_node("mobile/connect/name").text
	gamestate.join_game(ip, player_name)

func _input(event):
	if Input.is_action_pressed("ui_right") and not event.is_echo():
		right()
	if Input.is_action_pressed("ui_left") and not event.is_echo():
		left()
	if event.is_action_pressed("toggle_menu"):
		var settings = get_node("SettingsGUI")
		settings.visible = !settings.visible
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
	if event.is_action_pressed("return"):
		get_tree().change_scene("res://lobby.tscn")

func start():
	var world = load("res://world.tscn").instance()
	
	get_node("mobile/speed").show()
	get_node("play").queue_free()
	get_node("UI").queue_free()
	get_node("car_showcase").queue_free()
	get_node("car").queue_free()
	set_process_input(false)
	add_child(world)
	var newtrack
	if track==1:
		newtrack = load("res://tracks/1/track1.tscn").instance()
		set_background(load("res://hdri/umhlanga_sunrise_2k.hdr"))
		get_node("AudioStreamPlayer").stream = load("res://assets/music/Theme of Agrual.ogg")
	
	if track==2:
		newtrack = load("res://tracks/2/track2.tscn").instance()
		set_background(load("res://hdri/moonless_golf_2k.hdr"))
		get_node("AudioStreamPlayer").stream = load("res://assets/music/Tactical Pursuit.ogg")
	if track==3:
		newtrack = load("res://tracks/3/track3.tscn").instance()
		set_background(load("res://hdri/cape_hill_2k.hdr"))
		get_node("AudioStreamPlayer").stream = load("res://assets/music/Pleasant Creek.ogg")
	if track==4:
		newtrack = load("res://tracks/4/track4.tscn").instance()
		set_background(load("res://hdri/spruit_sunrise_2k.hdr"))
		get_node("AudioStreamPlayer").stream = load("res://assets/music/Pizza Dungeon.ogg")
	if track==5:
		newtrack = load("res://tracks/5/track5.tscn").instance()
		set_background(load("res://hdri/syferfontein_6d_clear_2k.hdr"))
		get_node("AudioStreamPlayer").stream = load("res://assets/music/Lively Meadow.ogg")
	world.get_node("track").add_child(newtrack)
	get_node("AudioStreamPlayer").play()
	var car_scene
	if car_num==1:
		car_scene = load("res://car/1/car.tscn")
	if car_num==2:
		car_scene = load("res://car/2/car2.tscn")
	if car_num==3:
		car_scene = load("res://car/3/car3.tscn")
	if car_num==4:
		car_scene = load("res://car/4/car4.tscn")
	var car = car_scene.instance()
	car.set_player_name("HugeGameArt")
	world.car = car
	world.get_node("vehicles").add_child(car)

func _on_settings_pressed():
	get_node("SettingsGUI").visible = true

func _on_start_pressed():
	gamestate.begin_game()


func multiplayer_dialog():
	get_node("mobile/connect").show()

func _on_track1_mouse_entered():
	update_background(track1, null)
func _on_track2_mouse_entered():
	update_background(track2, null)
func _on_track3_mouse_entered():
	update_background(track3, null)

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

func update_background(img, col):
	var mesh = get_node("car_showcase/Camera/MeshInstance")
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

func _on_playbtn_pressed():
	remove_child(get_node("car_load1"))
	remove_child(get_node("car_load2"))
	get_node("play").hide()
	
	get_node("UI").show()

func set_background(background):
	environment.background_sky.panorama = background


func _on_AudioStreamPlayer_finished():
	get_node("AudioStreamPlayer").play()


	


