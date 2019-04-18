extends Spatial
var b38 = preload("res://assets/ui/38.png")
var b37 = preload("res://assets/ui/37.png")
var b36 = preload("res://assets/ui/36.png")
var b39 = preload("res://assets/ui/39.png")
var m3 = preload("res://assets/voice/3.ogg")
var m2 = preload("res://assets/voice/2.ogg")
var m1 = preload("res://assets/voice/1.ogg")
var begin = preload("res://assets/voice/begin.ogg")
var round1 = preload("res://assets/voice/round_1.ogg")
var num = 4
var endaudio = false
var car = null
func _ready():
	get_node("countdown/Timer").start()

func set_text():
	print("ready")

func _input(event):
	if event.is_action_pressed("toggle_menu"):
		var settings = get_node("/root/lobby/Viewport/SettingsGUI")
		settings.visible = !settings.visible
	if event.is_action_pressed("toggle_fullscreen"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())

func _on_Timer_timeout():
	num-=1
	if num == 3:
		get_node("countdown/number").texture_normal = b38
		get_node("countdown/audio").stream = m3
		get_node("countdown/audio").play()
	if num == 2:
		get_node("countdown/number").texture_normal = b37
		get_node("countdown/audio").stream = m2
		get_node("countdown/audio").play()
	if num == 1:
		get_node("countdown/number").texture_normal = b36
		get_node("countdown/audio").stream = m1
		get_node("countdown/audio").play()
	if num == 0:
		get_node("countdown/number").texture_normal = b39
		get_node("countdown/audio").stream = begin
		get_node("countdown/audio").play()
	if num == -1:
		get_node("countdown/number").texture_normal = null
		num = 4
		get_node("countdown/Timer").stop()
		get_node("countdown/audio").stream = round1
		get_node("countdown/audio").play()

func audioend():
	endaudio=true

func _on_audio_finished():
	if endaudio:
		gamestate.end_game()
