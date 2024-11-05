extends Node2D

signal resetPosition(who)
signal gameOver()
signal checkGameOver()
signal levelCompleted()
signal checkLevelCompleted()
signal changeSpeed(speedType)
signal movePlayer(location)

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
@export var jumpInstance : PackedScene
@export var ziplineMiddle : PackedScene
@export var coinInstance : PackedScene
@export var keyBindingInstance : PackedScene
@export var skipInstance :PackedScene

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
@onready var jumpBoostList = $objectList/jumpBoosts
@onready var coinList = $objectList/coins
@onready var keyBindingList = $objectList/keyBindings
@onready var skipList = $objectList/skips

var player1 
var killWall
var countdownUI
var statusMessage
var restartButton
var music

var score = 0
var musicTime = 0.0

@onready var timerText
@onready var player
@onready var camera
@onready var scoreText
@onready var powerupUI

var textPopupScene1
var restartCheckpoint = false
var skipping = false
var timeMultiplier = 1.0
var skipCoords : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.gameOver = false
	Globals.inLevel = false
	loadLevel()
	Globals.time = 0.0
	var backgroundName : String = "Lvl1"
	if levelFile.begins_with("Tutorial"):
		Globals.setBPM(155)
		Globals.currentSongFileName = "Tutorial_New_155bpm.mp3"
		backgroundName = "Lvl0"
	if levelFile.begins_with("Level 1"):
		Globals.setBPM(155)
		Globals.currentSongFileName = "Level1_Main_155bpm.mp3"
		backgroundName = "Lvl1"
	if levelFile.begins_with("Level 2"):
		Globals.setBPM(156)
		Globals.currentSongFileName = "Level2_Main_156bpm_V2.mp3"
		backgroundName = "Lvl2"
		
	if levelFile.begins_with("Tutorial"):
		var popUpScene = load("res://worldObjects/onboardingPopUp.tscn")
		var popUpInstance = popUpScene.instantiate()
		$Camera2D.add_child(popUpInstance)
		$Camera2D/onboardingPopUp/tutorialSlides.play()
	# load the actionArrays (This must happen after bpm is set)
	$objectList/actionIndicators.load_array()
	# set bpm of all pulsing objects
	for object in get_tree().get_nodes_in_group("pulsingObjects"):
		object.setBPM()
		
	# Load background
	var backgroundScene = load("res://backgrounds/" + backgroundName + "Background.tscn")
	if backgroundScene:
		var backgroundInstance = backgroundScene.instantiate()
		$Background.add_child(backgroundInstance)
	# Failsafe: load Lvl1
	else:
		backgroundScene = load("res://backgrounds/Lvl1Background.tscn")
		var backgroundInstance = backgroundScene.instantiate()
		$Background.add_child(backgroundInstance)
	
	camera = $Camera2D
	player1 = playersList.get_node("Player1")
	timerText = $CanvasLayer/Timer
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
	self.changeSpeed.connect(_onChangeSpeed)
	self.movePlayer.connect(_onMovePlayer)

	# Prep players
	player1.editing = false
	if Globals.customStart:
		#we are starting at a user picked place
		player1.global_position = Globals.startP1Coords
		get_node("Camera2D").moveCamera(player1.global_position.x)
		var distance = abs(0.0 - player1.global_position.x)
		var playerSpeed = player1.SPEED
		musicTime = distance / Globals.pixelsPerFrame
		Globals.time += musicTime
	elif Globals.relocateToCheckpoint and Globals.checkpoint != null:
		player1.global_position = Globals.checkpoint
		get_node("Camera2D").moveCamera(player1.global_position.x)
		var distance = abs(0.0 - player1.global_position.x)
		var playerSpeed = player1.SPEED
		musicTime = distance / Globals.pixelsPerFrame
		Globals.time = 0.0
		Globals.time += musicTime
	#killWall = get_node("KillWall")start
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
	print("starting")
	Globals.inLevel = true
	if !Globals.customStart and !Globals.relocateToCheckpoint:
		Globals.time = 0.0
		Globals.relocateToCheckpoint = false

func loadAudio():
	if !Globals.currentSongFileName:
		return
	var audioPath = "res://audioTracks/" + Globals.currentSongFileName
	var newAudio = load(audioPath) as AudioStream
	music.stream = newAudio
	#music.stream.loop = false

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
		"powerups": [powerupInstance, powerupList],
		"jumpBoosts": [jumpInstance, jumpBoostList],
		"coins": [coinInstance, coinList],
		"keyBindings":[keyBindingInstance, keyBindingList],
		"skips":[skipInstance, skipList]}
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
			var instancedObj = instance.instantiate()
			var posPoints = []
			
			for pos in line.split(", "):
				pos = pos.replace(",", "")
				if pos.is_valid_float():
					posPoints.append(pos.to_float())
				else:
					posPoints.append(pos)
				
			instancedObj.position = Vector2(posPoints[0], posPoints[1])
			instanceParent.add_child(instancedObj)
			
			#check if zipline, TODO make this more 
			# TODO: Finish zipline line
			if name == "ziplines":
				var startPos = Vector2(posPoints[0], posPoints[1])
				var endPos = Vector2(posPoints[2], posPoints[3])
				instancedObj.get_node("ziplineStart").global_position = startPos
				instancedObj.get_node("ziplineEnd").global_position = endPos
				var vec1 = instancedObj.get_node("ziplineStart/Marker2D").global_position
				var vec2 = instancedObj.get_node("ziplineEnd/Marker2D").global_position
				var tgtPosX = (vec1.x + vec2.x)/2
				var tgtPosY = (vec1.y + vec2.y)/2
				var connectLine = ziplineMiddle.instantiate()
				connectLine.position = Vector2(tgtPosX, tgtPosY)
				connectLine.rotation = vec1.angle_to_point(vec2)
				var defaultLen = 195
				var tgtLen = (vec2 - vec1).length()
				connectLine.scale.x = tgtLen / defaultLen
				objectList.add_child(connectLine)
				
			if name =="platformBlocks":
				instancedObj.setTileMaps(posPoints.duplicate()) 
				instancedObj.add_to_group("platforms")
				
			if name == "keyBindings":
				instancedObj.setImage(posPoints)
			if name == "enemies":
				instancedObj.setEnemyType(posPoints)
			
		elif ".mp3" in line:
			# audio file
			print("Changing audio to: ", line)
			Globals.currentSongFileName = line
	
	# load the actionArrays
	$objectList/actionIndicators.load_array()
	$objectList/skips.loadArray()
	
	if levelFile.begins_with("Level 2"):
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
	var closestPoint = self.getNearestCheckpoint(player1)
	if closestPoint != null:
		Globals.checkpoint = closestPoint.position
	showGameOver()
	Globals.inLevel = false

func showGameOver():
	Engine.time_scale = 1.0
	music.stop()
	Globals.gameOver = true
	Globals.inLevel = false
	$LevelUI/GameOverScreen.visible = true
	$LevelUI/GameOverScreen.playMusic()
	Globals.restartLevelData()
	Engine.time_scale = 1.0
	
func showLevelCompleted():
	Engine.time_scale = 1.0
	music.stop()
	Globals.gameOver = true
	Globals.inLevel = false
	$LevelUI/levelCompleteScreen.emit_signal("updateScoreData")
	$LevelUI/levelCompleteScreen.visible = true
	var newAudio = load("res://audioTracks/CourseComplete_153bpm.mp3") as AudioStream
	$LevelUI/levelCompleteScreen/jingle.stream = newAudio
	$LevelUI/levelCompleteScreen/jingle.play()
	
	Globals.restartLevelData()
	await get_tree().create_timer(5.0).timeout
	#statusMessage.text = "Level Completed!"
	#restartButton.visible = true
	
func _onLevelCompleted():
	showLevelCompleted()
	Globals.inLevel = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	updateTime(delta)
	if Input.is_action_just_pressed("pause") and !$LevelUI/GameOverScreen.visible and !$LevelUI/levelCompleteScreen.visible:
		#do go to pause instead
		#get_tree().change_scene_to_file("res://ui/landingPage.tscn")
		$Camera2D/Music.stream_paused = true
		Globals.paused = true
		$LevelUI/PauseScreen.visible = true
		Engine.time_scale = 0.0
	if Globals.vertical:
		camera.emit_signal("moveCameraY", player1.position.y)
	elif Globals.resetCamera:
		camera.emit_signal("moveCameraY", player1.position.y)
	if Globals.time >= 3.0 and !Globals.inLevel and !Globals.paused and !Globals.customStart and !Globals.relocateToCheckpoint and !Globals.gameOver:
		startGame()
	elif (Globals.customStart or Globals.relocateToCheckpoint) and !Globals.inLevel and Globals.time >= musicTime + 3.0 and !Globals.gameOver:
		print("global time: ", Globals.time, " music time: ", musicTime)
		startGame()
		
	if skipping:
		#see player x matches to skip x
		if skipCoords.x <= camera.global_position.x - 244:
			skipping = false
			player1.emit_signal("notSkipping")
			emit_signal("changeSpeed", 0)
	
func updateTime(delta: float):
	if Globals.inLevel:
		Globals.time = Globals.time  + (delta*timeMultiplier)
	timerText.text = str(round_to_dec(Globals.time, 2))
	
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
	print("The nearest point is: ", nearestPoint)
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
	scoreText.lerpText(int(score))
	if id == "Player1":
		textPopupScene1.initText(scoreToAdd, player1.position)
		
func _onChangeSpeed(speedType):
	if speedType > 0:			# Speed up
		music.pitch_scale = 2
		Globals.scrollSpeed = 2
		timeMultiplier = 2.0
	elif speedType < 0:			# Speed down
		music.pitch_scale = 0.5
		Globals.scrollSpeed = 0.5
		timeMultiplier = 0.5
	else:						# Return to regular
		music.pitch_scale = 1
		Globals.scrollSpeed = 1
		timeMultiplier = 1.0

func _onMovePlayer(location : Vector2):
	#we have to move player based on new global loaction
	player1.global_position = location
	skipCoords = location
	skipping = true
	emit_signal("changeSpeed", 1)
	player1.emit_signal("skipping")
	
