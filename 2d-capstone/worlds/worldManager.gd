extends Node2D

signal resetPosition(who)
signal gameOver()
signal checkGameOver()
signal levelCompleted()
signal checkLevelCompleted()

var player1 
var player2
var killWall
var countdownUI
var statusMessage
var restartButton
var music
var checkpoints

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
	#timerText = $CanvasLayer/Timer
	player = $Player1
	#camera = $Camera2D
	checkpoints = $CheckpointManager
	#scoreText = $CanvasLayer/Score
	music = $AudioStreamPlayer2D
	
	# Setting signals
	self.resetPosition.connect(_onResetPosition)

	self.gameOver.connect(_onGameOver)
	self.checkGameOver.connect(_onCheckGameOver)
	self.checkLevelCompleted.connect(_onCheckLevelCompleted)
	self.levelCompleted.connect(_onLevelCompleted)

	#self.gameOver.connect(_onGameOver)
	#self.checkGameOver.connect(_onCheckGameOver)

	# Getting nodes to manage
	player1 = get_node("Player1")
	#player2 = get_node("Player2")
	#killWall = get_node("KillWall")
	#countdownUI = get_node("LevelUI")
	#statusMessage = countdownUI.get_node("Box").get_node("Status")
	#restartButton = countdownUI.get_node("Box").get_node("RestartButton")

	# Start game
	#restartButton.visible = false
	#changeCountdown()
	#await get_tree().create_timer(3.0).timeout
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

func _onCheckLevelCompleted():
	print("checking if level completed!")
	var allGoals= get_tree().get_nodes_in_group("goals") 
	#I dont think I should be checking this all the time
	var allReached = true
	for goal in allGoals:
		if goal.get_class() == "Node2D" and !goal.reached:
			allReached = false
			
	#all player goals have been reached 
	print("all reached = ", allReached)
	if allReached:
		self.emit_signal("levelCompleted")

func _onGameOver():
	showGameOver()
	Globals.inLevel = false

func showGameOver():
	statusMessage.text = "Game over!"
	restartButton.visible = true
	
func showLevelCompleted():
	statusMessage.text = "Level Completed!"
	restartButton.visible = true
	
func _onLevelCompleted():
	showLevelCompleted()
	Globals.inLevel = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#updateTime(delta)
	pass

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

# Helper function that grabs the target player's closest forward checkpoint
func getNearestCheckpoint(who):
	var nearestPoint = checkpoints.get_child(0)
	var shortestDistance = who.position.distance_to(nearestPoint.position)
	for i in checkpoints.get_children():
		print("Checking: ", i)
		var distance = who.position.distance_to(i.position)
		# Check if checkpoint in front of player
		var direction = (i.position.x - who.position.x)
		print("dir: ", direction)
		if (direction >= 0):
			if distance < shortestDistance:
				#print("Closest node: ", i)
				nearestPoint = i
				shortestDistance = distance
	return nearestPoint
	
# Basic checkpointing system
func _onResetPosition(who):
	if who.name == "Player1":
		print("resetting player pos")
		#player1.position.x = killWall.position.x + 50
		var nearestPoint = getNearestCheckpoint(who)

		#player1.velocity -= player2.get_gravity() * player2.get_process_delta_time() * 50
		who.emit_signal("relocate", nearestPoint)
		pass
	elif who.name == "Player2":
		#player2.position.x = killWall.position.x + 50
		who.velocity -= who.get_gravity() * who.get_process_delta_time() * 50
		pass


func _onEndGameBodyEntered(body:Node2D):
	if (body.is_in_group("players")):
		print("Game over!")
		self.emit_signal("gameOver")
