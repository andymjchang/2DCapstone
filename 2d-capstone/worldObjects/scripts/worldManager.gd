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
@export var ziplineInstance : PackedScene

@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var killFloorsList = $objectList/killFloors
@onready var enemiesList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var p1checkpointsList = $objectList/player1checkpoints
@onready var p2checkpointsList = $objectList/player2checkpoints
@onready var playersList = $objectList/players
@onready var ziplineList = $objectList/ziplines

var player1 
var player2
var killWall
var countdownUI
var statusMessage
var restartButton
var music

var time : float = 0
var score = 0

@onready var timerText
@onready var player
@onready var camera
@onready var scoreText

var textPopupScene1
var textPopupScene2


# Called when the node enters the scene tree for the first time.
func _ready():
	loadLevel()
	timerText = $CanvasLayer/Timer
	player1 = playersList.get_node("Player1")
	player2 = playersList.get_node("Player2")
	camera = $Camera2D
	scoreText = $CanvasLayer/Score
	
	# intialize text popup node
	textPopupScene1 = $Camera2D/ScorePopup1
	textPopupScene2 = $Camera2D/ScorePopup2
	textPopupScene1.initPosition(player1)
	textPopupScene2.initPosition(player2)
	
	music = camera.get_node("Music")
	loadAudio()
	
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
	Globals.inLevel = false
	restartButton.visible = false
	changeCountdown()
	#startGame()
	
func startGame():
	music.play(0.0)
	Globals.inLevel = true

func loadAudio():
	if !Globals.currentSongFileName:
		return
	var audioPath = "res://audioTracks/" + Globals.currentSongFileName
	var newAudio = load(audioPath) as AudioStream
	music.stream = newAudio

func loadLevel():
	# set file to load
	if Globals.currentSongFileName:
		levelFile = Globals.currentEditorFileName
	if Globals.curFile:
		levelFile = Globals.curFile
	
	print("level nameL ", levelFile)
	var content = FileAccess.open("res://levelData/" + levelFile + ".dat", FileAccess.READ).get_as_text()
	var instanceList = {"platformBlocks": [platformBlockInstance, platformBlocksList], 
		"goalBlocks": [goalBlockInstance, goalBlocksList],
		"killFloors": [killFloorInstance, killFloorsList],
		"actionIndicators": [actionIndicatorInstance, actionIndicatorsList], 
		"player1checkpoints": [checkpointInstance, p1checkpointsList],
		"player2checkpoints": [checkpointInstance, p2checkpointsList], 
		"enemies": [enemyInstance, enemiesList],
		"player1": [player1Instance, playersList],
		"player2": [player2Instance, playersList],
		"ziplines": [ziplineInstance, ziplineList]}
	var instance
	var instanceParent
	for line in content.split("\n"):
		#print("Current line: ", line)
		if line in instanceList.keys():
			instance = instanceList.get(line)[0]
			instanceParent = instanceList.get(line)[1]
		# Position
		#does not work with goal/checkpoints
		if line.contains(", "):
			#print("Object: ", instance)
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				posPoints.append(pos.to_float())
			instancedObj.position = Vector2(posPoints[0], posPoints[1])
			#print("instance parent: ", instanceParent)
			instanceParent.add_child(instancedObj)
	
	# load the actionArrays
	$objectList/actionIndicators.load_array()

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
	music.stop()
	statusMessage.text = "Level Completed!"
	restartButton.visible = true
	
func _onLevelCompleted():
	showLevelCompleted()
	Globals.inLevel = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	updateTime(delta)
	if Input.is_action_just_pressed("toMainMenu"):
		get_tree().change_scene_to_file("res://ui/landingPage.tscn")
		
	if time >= 3.0 and !Globals.inLevel:
		startGame()

func updateTime(delta: float):
	time = time + delta
	timerText.text = str(round_to_dec(time, 2))
	
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
#func updateScore(indicator_position):
	#var score_to_add = 100 - (indicator_position - player1.position.x)
	#score += score_to_add
	#scoreText.text = str(int(score))
	#textPopupScene1.initText(score, player1.position)

# Helper function that grabs the target player's closest forward checkpoint
func getNearestCheckpoint(who):
	var checkpointPath = who.name.to_lower() + "checkpoints"
	var viableCheckpoints = []
	for i in objectList.get_node(checkpointPath).get_children():
		#print("Checking: ", i)
		# Check if checkpoint in front of player
		var direction = (i.position.x - who.position.x)
		if (direction >= 0):
			viableCheckpoints.append(i)
	#print("Viable checkpoints: ", viableCheckpoints)
	var nearestPoint = viableCheckpoints[0]
	var shortestDistance = who.position.distance_to(viableCheckpoints[0].position)
	for i in viableCheckpoints:
		var distance = who.position.distance_to(i.position)
		if distance < shortestDistance:
			nearestPoint = i
			shortestDistance = distance
	#print("Relocating to: ", nearestPoint.position)
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

func _onRunBoundsBodyEntered(body: Node2D) -> void:
	if (body.name.contains("Player")):
		print("Entering max run bounds")
		body.hitBounds = true


func _onRunBoundsBodyExited(body: Node2D) -> void:
	if (body.name.contains("Player")):
		print("Leaving max run bounds")
		body.hitBounds = false
func _onScored(id, p_score):
	var scoreToAdd = 100 - p_score
	score += scoreToAdd
	scoreText.text = str(int(score))
	if id == "Player1":
		textPopupScene1.initText(scoreToAdd, player1.position)
	if id == "Player2":
		textPopupScene2.initText(scoreToAdd, player2.position)
