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
var music

var time : float = 0
var bpm: int = 100
var score = 0

@onready var timerText
@onready var player
@onready var camera
@onready var scoreText

var textPopupScene = preload("res://worldObjects/scoreText.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	timerText = $CanvasLayer/Timer
	player = $Player1
	camera = $Camera2D
	scoreText = $CanvasLayer/Score
	music = $AudioStreamPlayer2D
	
	# Setting signals
	self.resetPosition.connect(_onResetPosition)
	self.gameOver.connect(_onGameOver)
	self.checkGameOver.connect(_onCheckGameOver)

	# Getting nodes to manage
	player1 = get_node("Player1")
	player2 = get_node("Player2")
	#killWall = get_node("KillWall")
	countdownUI = get_node("LevelUI")
	statusMessage = countdownUI.get_node("Box").get_node("Status")
	restartButton = countdownUI.get_node("Box").get_node("RestartButton")

	# Start game
	restartButton.visible = false
	changeCountdown()
	await get_tree().create_timer(3.0).timeout
	Globals.inLevel = true
	music.play(0.0)

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
	updateTime(delta)

func updateTime(delta: float):
	time = time + delta
	timerText.text = str(round_to_dec(time, 2))
	
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func updateScore(indicator_position):
	var score_to_add = 100 - (indicator_position - player.position.x)
	score += score_to_add
	scoreText.text = str(int(score))
	var textPopup = textPopupScene.instantiate()
	textPopup.initText(score_to_add, player.position)
	add_child(textPopup)
	
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
