extends Node2D

signal resetPosition(who)
signal gameOver()
signal checkGameOver()

var player1 
var player2
var killWall
var countdownUI
var statusMessage
var restartButton

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setting signals
	self.resetPosition.connect(_onResetPosition)
	self.gameOver.connect(_onGameOver)
	self.checkGameOver.connect(_onCheckGameOver)

	# Getting nodes to manage
	player1 = get_node("Player1")
	player2 = get_node("Player2")
	killWall = get_node("KillWall")
	countdownUI = killWall.get_node("LevelUI")
	statusMessage = countdownUI.get_node("Box").get_node("Status")
	restartButton = countdownUI.get_node("Box").get_node("RestartButton")

	# Start game
	restartButton.visible = false
	changeCountdown()
	await get_tree().create_timer(3.0).timeout
	Globals.inLevel = true

func changeCountdown():
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "2"
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "1"
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "Go!"
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = ""

func _onCheckGameOver():
	print("Checking if both dead")
	if player1.dead and player2.dead:
		print("Both dead")
		self.emit_signal("gameOver")

func _onGameOver():
	showGameOver()
	Globals.inLevel = false

func showGameOver():
	statusMessage.text = "Game over!"
	restartButton.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(killWall.position.x)
	pass

# Hard coded right now
func _onResetPosition(who):
	print("resetting player pos")
	if who == "Player1":
		#player1.position.x = killWall.position.x + 50
		player1.velocity -= player2.get_gravity() * player2.get_process_delta_time() * 50
		pass
	elif who == "Player2":
		#player2.position.x = killWall.position.x + 50
		player2.velocity -= player2.get_gravity() * player2.get_process_delta_time() * 50
		pass
