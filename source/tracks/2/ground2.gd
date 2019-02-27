extends Area
var ROUND = 1
var round2 = preload("res://assets/voice/round_2.ogg")
var finalround = preload("res://assets/voice/final_round.ogg")
var gameover = preload("res://assets/voice/game_over.ogg")
var winner = preload("res://assets/voice/winner.ogg")


func _ready():
	pass 

func game_over(body):
	if str(body).begins_with("[VehicleBody"):
		print("Game Over")
		get_tree().get_root().get_node("lobby/world").audioend()
		$"/root/lobby/world/countdown/audio".stream = gameover
		$"/root/lobby/world/countdown/audio".play()

func _on_StaticBody2_body_entered(body):
	game_over(body)


func _on_Area_body_entered(body):
	game_over(body)

func _on_goal_body_entered(body):
	nextround(body)

func _on_goal2_body_entered(body):
	nextround(body)

func _on_goal4_body_entered(body):
	nextround(body)

func _on_goal5_body_entered(body):
	nextround(body)

func nextround(body):
	if str(body).begins_with("[VehicleBody"):
		if ROUND < 3:
			ROUND += 1
			$"/root/lobby/world/round".text="round " + str(ROUND) + " of 3"
			if ROUND == 2:
				$"/root/lobby/world/countdown/audio".stream = round2
			if ROUND == 3:
				$"/root/lobby/world/countdown/audio".stream = finalround
				
			$"/root/lobby/world/countdown/audio".play()
		else:
			get_tree().get_root().get_node("lobby/world").audioend()
			$"/root/lobby/world/countdown/audio".stream = winner
			$"/root/lobby/world/countdown/audio".play()
