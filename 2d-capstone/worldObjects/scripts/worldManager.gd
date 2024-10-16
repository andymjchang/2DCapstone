extends Node2D

signal resetPosition(who)
signal gameOver()
signal checkGameOver()
signal levelCompleted()
signal checkLevelCompleted()
signal changeSpeed(speedType)

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
@export var slideWallInstance : PackedScene
@export var powerupInstance : PackedScene

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
@onready var slideWallList = $objectList/slideWalls
@onready var powerupList = $objectList/powerups

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
var restartCheckpoint = false

# Called when the node enters the scene tree for the first time.
func _ready():
	loadLevel()
	
	# FIXME: temporary bpm setting
	if levelFile.begins_with("Lvl0."):
		Globals.setBPM(155)
	if levelFile.begins_with("Lvl1."):
		Globals.setBPM(155)
	if levelFile.begins_with("Lvl2."):
		Globals.setBPM(156)
		
	if levelFile == "Lvl0.2":
		var popUpScene = load("res://worldObjects/onboardingPopUp.tscn")
		var popUpInstance = popUpScene.instantiate()
		$Camera2D.add_child(popUpInstance)
		$Camera2D/onboardingPopUp/tutorialSlides.play()
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
	music.stream.loop = false
	loadAudio()
	
	# Setting signals
	self.resetPosition.connect(_onResetPosition)
	self.gameOver.connect(_onGameOver)
	self.checkGameOver.connect(_onCheckGameOver)
	self.checkLevelCompleted.connect(_onCheckLevelCompleted)
	self.levelCompleted.connect(_onLevelCompleted)
	self.changeSpeed.connect(_onChangeSpeed)

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
	emit_signal("changeSpeed", 0)
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
	music.stream.loop = false

func loadLevel():
	# set file to load
	#if Globals.currentSongFileName:
		#levelFile = Globals.currentEditorFileName
	if Globals.curFile:
		levelFile = Globals.curFile
	
	print("level name ", levelFile)
	var content = FileAccess.open("res://levelData/" + levelFile + ".dat", FileAccess.READ).get_as_text()
	var instanceList = {"platformBlocks": [platformBlockInstance, platformBlocksList], 
		"goalBlocks": [goalBlockInstance, goalBlocksList],
		"killFloors": [killFloorInstance, killFloorsList],
		"actionIndicators": [actionIndicatorInstance, actionIndicatorsList], 
		"playerCheckpoints": [checkpointInstance, p1checkpointsList],
		"enemies": [enemyInstance, enemiesList],
		"player": [player1Instance, playersList],
		"breakableWalls" : [breakableWallInstance, breakableWallList],
		"ziplines": [ziplineInstance, ziplineList],
		"slideWalls": [slideWallInstance, slideWallList],
		"powerups": [powerupInstance, powerupList]}
	var instance
	var instanceParent
	var name = ""
	for line in content.split("\n"):
		#print("Current line: ", line)
		if line in instanceList.keys():
			name = line
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
			#check if zipline, TODO make this more 
			if name == "ziplines":
				print("pos points, ", posPoints)
				var startPos = Vector2(posPoints[0], posPoints[1])
				var endPos = Vector2(posPoints[2], posPoints[3])
				instancedObj.get_node("ziplineStart").global_position = startPos
				instancedObj.get_node("ziplineEnd").global_position = endPos
				
			#print("instance!: ", name)
			
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
	music.stop()
	Engine.time_scale = 0.0
	$LevelUI/Box/GameOverScreen.visible = true
	
func showLevelCompleted():
	music.stop()
	Engine.time_scale = 0.0
	$LevelUI/Box/GameOverScreen.visible = true
	#statusMessage.text = "Level Completed!"
	#restartButton.visible = true
	
func _onLevelCompleted():
	showLevelCompleted()
	Globals.inLevel = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	updateTime(delta)
	if Input.is_action_just_pressed("toMainMenu"):
		#do go to pause instead
		#get_tree().change_scene_to_file("res://ui/landingPage.tscn")
		$Camera2D/Music.stream_paused = true
		Globals.paused = true
		$LevelUI/Box/PauseScreen.visible = true
		Engine.time_scale = 0.0
		
	if time >= 3.0 and !Globals.inLevel and !Globals.paused:
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
	var viableCheckpoints = []
	var nearestPoint = null
	if len(objectList.get_node("playerCheckpoints").get_children()) > 0:
		for i in objectList.get_node("playerCheckpoints").get_children():
			#print("Checking: ", i)
			# Check if checkpoint behind player
			var direction = (i.position.x - who.position.x)
			if (direction < 0):
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

func _onChangeSpeed(speedType):
	if speedType > 0:			# Speed up
		music.pitch_scale = 2
		Globals.scrollSpeed = 2
	elif speedType < 0:			# Speed down
		music.pitch_scale = 0.5
		Globals.scrollSpeed = 0.5
	else:						# Return to regular
		music.pitch_scale = 1
		Globals.scrollSpeed = 1
