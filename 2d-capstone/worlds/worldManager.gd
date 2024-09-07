extends Node2D

signal resetPosition(who)

var player1 
var player2
var killWall
var countdownUI

# Called when the node enters the scene tree for the first time.
func _ready():
	self.resetPosition.connect(_onResetPosition)
	player1 = get_node("Player1")
	player2 = get_node("Player2")
	killWall = get_node("KillWall")
	countdownUI = get_node("LevelUI")
	changeCountdown()
	await get_tree().create_timer(3.0).timeout
	Globals.inLevel = true
	pass # Replace with function body.


func changeCountdown():
	await get_tree().create_timer(1.0).timeout
	countdownUI.get_node("Countdown").text = "2"
	await get_tree().create_timer(1.0).timeout
	countdownUI.get_node("Countdown").text = "1"
	await get_tree().create_timer(1.0).timeout
	countdownUI.get_node("Countdown").text = "Go!"
	await get_tree().create_timer(1.0).timeout
	countdownUI.get_node("Countdown").text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(killWall.position.x)
	pass

# Hard coded right now
func _onResetPosition(who):
	print("resetting player pos")
	if who == "Player1":
		player1.position.x = killWall.position.x + 45
		player1.velocity -= player2.get_gravity() * player2.get_process_delta_time() * 50
		pass
	elif who == "Player2":
		player2.position.x = killWall.position.x + 45
		player2.velocity -= player2.get_gravity() * player2.get_process_delta_time() * 50
		pass
