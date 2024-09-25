extends Node2D

signal resetPosition(who)
signal gameOver()
signal checkGameOver()
signal levelCompleted()
signal checkLevelCompleted()

@export var levelFile : String
@export var platformBlockInstance : PackedScene
@export var goalBlockInstance : PackedScene
@export var killFloorInstance : PackedScene
@export var actionIndicatorInstance : PackedScene
@export var checkpointInstance : PackedScene
@export var player1Instance : PackedScene
@export var player2Instance : PackedScene
@export var enemyInstance : PackedScene

@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var killFloorsList = $objectList/killFloors
@onready var enemiesList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var checkpointsList = $objectList/checkpoints
@onready var playersList = $objectList/players

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
	loadLevel()
	timerText = $CanvasLayer/Timer
	player1 = playersList.get_node("Player1")
	player2 = playersList.get_node("Player2")
	camera = $Camera2D
	scoreText = $CanvasLayer/Score
	music = camera.get_node("Music")
	
	# Setting signals
	self.resetPosition.connect(_onResetPosition)
	self.gameOver.connect(_onGameOver)
	self.checkGameOver.connect(_onCheckGameOver)
	self.checkLevelCompleted.connect(_onCheckLevelCompleted)
	self.levelCompleted.connect(_onLevelCompleted)

	# Prep players
	player1.editing = false
	player2.editing = false
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


func loadLevel():
	var content = FileAccess.open("res://levelData/" + levelFile + ".dat", 1).get_as_text()
	var instanceList = {"platformBlocks": [platformBlockInstance, platformBlocksList], 
		"goalBlocks": [goalBlockInstance, goalBlocksList],
		"killFloors": [killFloorInstance, killFloorsList],
		"actionIndicators": [actionIndicatorInstance, actionIndicatorsList], 
		"checkpoints": [checkpointInstance, checkpointsList], 
		"enemies": [enemyInstance, enemiesList],
		"player1": [player1Instance, playersList],
		"player2": [player2Instance, playersList]}
	var instance
	var instanceParent
	for line in content.split("\n"):
		#print("Current line: ", line)
		if line in instanceList.keys():
			instance = instanceList.get(line)[0]
			instanceParent = instanceList.get(line)[1]
		# Position
		if line.contains(", "):
			#print("Object: ", instance)
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				posPoints.append(pos.to_float())
			instancedObj.position = Vector2(posPoints[0], posPoints[1])
			instanceParent.add_child(instancedObj)

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
	var nearestPoint = objectList.get_node(who.name + "checkpoints").get_child(0)
	var shortestDistance = who.position.distance_to(nearestPoint.position)
	for i in objectList.get_node(who.name + "checkpoints").get_children():
		#print("Checking: ", i)
		var distance = who.position.distance_to(i.position)
		# Check if checkpoint in front of player
		var direction = (i.position.x - who.position.x)
		#print("dir: ", direction)
		if (direction >= 0):
			if distance < shortestDistance:
				#print("foClosest node: ", i)
				nearestPoint = i
				shortestDistance = distance
	print("Relocating to: ", nearestPoint.position)
	return nearestPoint
	
# Basic checkpointing system
func _onResetPosition(who):
	if who.name == "Player1":
		var nearestPoint = getNearestCheckpoint(who)
		who.emit_signal("relocate", nearestPoint)
		pass
	elif who.name == "Player2":
		var nearestPoint = getNearestCheckpoint(who)
		who.emit_signal("relocate", nearestPoint)
		pass


func _onEndGameBodyEntered(body:Node2D):
	if (body.is_in_group("players")):
		print("Game over!")
		self.emit_signal("gameOver")
