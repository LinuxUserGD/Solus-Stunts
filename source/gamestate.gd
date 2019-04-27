extends Node
const DEFAULT_PORT = 10567
const MAX_PEERS = 12
var player_name = ""
var track = 0
var players = {}
var car_num = 1
var car_num2 = 1
var x = 0
var car_id = null

signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/world3D/world2")):
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else:
			unregister_player(id)
			for p_id in players:
				rpc_id(p_id, "unregister_player", id)

func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")

func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

remote func register_player(id, new_player_name):
	if (get_tree().is_network_server()):
		rpc_id(id, "register_player", 1, player_name) 
		for p_id in players:
			rpc_id(id, "register_player", p_id, players[p_id])
			rpc_id(p_id, "register_player", id, name)
	players[id] = new_player_name
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(tr, car_number, car_number2):
	$"/root/lobby/car".queue_free()
	var world = load("res://world.tscn").instance()
	$"/root/lobby".add_child(world)
	$"/root/lobby/World".queue_free()
	$"/root/lobby".set_process_input(false)
	$"/root/lobby/Viewport".queue_free()
	$"/root/lobby/World/car_showcase".queue_free()
	
	
	var car_scene
	if car_number==1:
		car_scene = load("res://car/1/car.tscn")
	if car_number==2:
		car_scene = load("res://car/2/car2.tscn")
	if car_number==3:
		car_scene = load("res://car/3/car3.tscn")
	if car_number==4:
		car_scene = load("res://car/4/car4.tscn")
		
	var car = car_scene.instance()
	car_id = get_tree().get_network_unique_id()
	car.set_name(str(car_id))
	car.set_network_master(get_tree().get_network_unique_id())
	car.set_player_name(player_name)
	world.get_node("vehicles").add_child(car)
	world.car = car
	$"/root/lobby/Viewport".queue_free()
	
	for pn in players:
		var car_scene2
		if car_number2==1:
			car_scene2 = load("res://car/1/car.tscn")
		if car_number2==2:
			car_scene2 = load("res://car/2/car2.tscn")
		if car_number2==3:
			car_scene2 = load("res://car/3/car3.tscn")
		if car_number2==4:
			car_scene2 = load("res://car/4/car4.tscn")
		car = car_scene2.instance()
		car.set_name(str(pn))
		car.set_network_master(pn)
		car.set_player_name(players[pn])
		world.get_node("vehicles").add_child(car)
		
	var newtrack

	if tr==1:
		newtrack = load("res://tracks/1/track1.tscn").instance()
		set_background(load("res://hdri/umhlanga_sunrise_2k.hdr"))
		car.get_node("Viewport2/AudioStreamPlayer").stream = load("res://assets/music/Theme of Agrual.ogg")
	
	if tr==2:
		newtrack = load("res://tracks/2/track2.tscn").instance()
		set_background(load("res://hdri/moonless_golf_2k.hdr"))
		car.get_node("Viewport2/AudioStreamPlayer").stream = load("res://assets/music/Tactical Pursuit.ogg")
	if tr==3:
		newtrack = load("res://tracks/3/track3.tscn").instance()
		set_background(load("res://hdri/cape_hill_2k.hdr"))
		car.get_node("Viewport2/AudioStreamPlayer").stream = load("res://assets/music/Pleasant Creek.ogg")
	if tr==4:
		newtrack = load("res://tracks/4/track4.tscn").instance()
		set_background(load("res://hdri/spruit_sunrise_2k.hdr"))
		car.get_node("Viewport2/AudioStreamPlayer").stream = load("res://assets/music/Pizza Dungeon.ogg")
	if tr==5:
		newtrack = load("res://tracks/5/track5.tscn").instance()
		set_background(load("res://hdri/syferfontein_6d_clear_2k.hdr"))
		car.get_node("Viewport2/AudioStreamPlayer").stream = load("res://assets/music/Lively Meadow.ogg")
	
	car.get_node("Viewport2/AudioStreamPlayer").play()
	
	world.get_node("track").add_child(newtrack)

	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false)

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	for p in players:
		rpc_id(p, "pre_start_game", track, car_num, car_num2)
	pre_start_game(track, car_num, car_num2)

func end_game():
	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null)
	get_tree().change_scene("res://lobby.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func set_background(background):
	$"/root/lobby/WorldEnvironment".environment.background_sky.panorama = background