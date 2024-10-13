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
@export var enemyInstance : PackedScene
@export var breakableWallInstance : PackedScene
@export var ziplineInstance : PackedScene

@onready var objectList = $objectList
@onready var platformBlocksList = $objectList/platformBlocks
@onready var goalBlocksList = $objectList/goalBlocks
@onready var killFloorsList = $objectList/killFloors
@onready var enemiesList = $objectList/enemies
@onready var actionIndicatorsList = $objectList/actionIndicators
@onready var p1checkpointsList = $objectList/playerCheckpoints
@onready var playersList = $objectList/players
@onready var breakableWallList = $objectList/breakableWalls
@onready var ziplineList = $objectList/ziplines

var player1 
var killWall
var countdownUI
var statusMessage
var restartButton
var music

var time : float = 0
var score = 0
var musicTime = 0.0

@onready var timerText
@onready var player
@onready var camera
@onready var scoreText

var textPopupScene1

# Called when the node enters the scene tree for the first time.
func _ready():
	loadLevel()
	
	# FIXME: temporary bpm setting
	if levelFile == "Lvl0.1":
		Globals.setBPM(120)
	if levelFile == "Lvl1.2":
		Globals.setBPM(155)
	if levelFile == "Lvl2.1":
		Globals.setBPM(156)
		
	# load the actionArrays (This must happen after bpm is set)
	$objectList/actionIndicators.load_array()
	# Load background
	var backgroundScene = load("res://backgrounds/" + levelFile + "Background.tscn")
	if backgroundScene:
		var backgroundInstance = backgroundScene.instantiate()
		$Background.add_child(backgroundInstance)
	# Failsafe: load Lvl1.2
	else:
		backgroundScene = load("res://backgrounds/Lvl1.2Background.tscn")
		var backgroundInstance = backgroundScene.instantiate()
		$Background.add_child(backgroundInstance)
	
	timerText = $CanvasLayer/Timer
	player1 = playersList.get_node("Player1")
	camera = $Camera2D
	scoreText = $CanvasLayer/Score
	
	# intialize text popup node
	textPopupScene1 = $Camera2D/ScorePopup1
	textPopupScene1.initPosition(player1)

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
	if Globals.customStart:
		#we are starting at a user picked place
		player1.global_position = Globals.startP1Coords
		get_node("Camera2D").moveCamera(player1.global_position.x)
		var distance = abs(0.0 - player1.global_position.x)
		var playerSpeed = player1.SPEED
		musicTime = distance / Globals.pixelsPerFrame
		print("time gone, ", musicTime)
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
	music.play(musicTime)
	Globals.inLevel = true

func loadAudio():
	if !Globals.currentSongFileName:
		return
	var audioPath = "res://audioTracks/" + Globals.currentSongFileName
	var newAudio = load(audioPath) as AudioStream
	music.stream = newAudio

func loadLevel():
	# set file to load
	#if Globals.currentSongFileName:
		#levelFile = Globals.currentEditorFileName
	if Globals.curFile:
		levelFile = Globals.curFile
	
	print("level nameL ", levelFile)
	var content = FileAccess.open("res://levelData/" + levelFile + ".dat", FileAccess.READ).get_as_text()
	var instanceList = {"platformBlocks": [platformBlockInstance, platformBlocksList], 
		"goalBlocks": [goalBlockInstance, goalBlocksList],
		"killFloors": [killFloorInstance, killFloorsList],
		"actionIndicators": [actionIndicatorInstance, actionIndicatorsList], 
		"playerCheckpoints": [checkpointInstance, p1checkpointsList],
		"enemies": [enemyInstance, enemiesList],
		"player": [player1Instance, playersList],
		"breakableWalls" : [breakableWallInstance, breakableWallList],
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
		elif line.contains(", "):
			#print("Object: ", instance)
			var instancedObj = instance.instantiate()
			var posPoints = []
			for pos in line.split(", "):
				posPoints.append(pos.to_float())
			instancedObj.position = Vector2(posPoints[0], posPoints[1])
			#print("instance parent: ", instanceParent)
			instanceParent.add_child(instancedObj)
			
		elif ".mp3" in line:
			# audio file
			print("Changing audio to: ", line)
			Globals.currentSongFileName = line
	
	# load the actionArrays
	$objectList/actionIndicators.load_array()
	if Globals.curFile == "Lvl2.1" or levelFile == "Lvl2.1":
		for platform in platformBlocksList.get_children():
			platform.get_node("sprite2D/TileMapLayer").visible = false
			platform.get_node("sprite2D/TileMapLayer2").visible = true

func changeCountdown():
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "2"
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "1"
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = "Go!"
	startGame()
	await get_tree().create_timer(1.0).timeout
	statusMessage.text = ""

func _onCheckGameOver():
	print("Checking if both dead")
	if player1.dead:
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
	statusMessage.visible = true
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
	var nearestPoint = null
	if len(objectList.get_node(checkpointPath).get_children()) > 0:
		for i in objectList.get_node(checkpointPath).get_children():
			#print("Checking: ", i)
			# Check if checkpoint in front of player
			var direction = (i.position.x - who.position.x)
			if (direction >= 0):
				viableCheckpoints.append(i)
		#print("Viable checkpoints: ", viableCheckpoints)
		if len(viableCheckpoints) > 0:
			nearestPoint = viableCheckpoints[0]
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


func _onEndGameBodyEntered(body:Node2D):
	if (body.is_in_group("players")):
		print("Game over!")
		self.emit_signal("gameOver")

func _onRunBoundsBodyEntered(body: Node2D) -> void:
	if (body.name.contains("Player")):
		#print("Entering max run bounds")
		body.hitBounds = true


func _onRunBoundsBodyExited(body: Node2D) -> void:
	if (body.name.contains("Player")):
		#print("Leaving max run bounds")
		body.hitBounds = false


func _onScored(id, p_score):
	var scoreToAdd = 100 - p_score
	score += scoreToAdd
	scoreText.text = str(int(score))
	if id == "Player1":
		textPopupScene1.initText(scoreToAdd, player1.position)
