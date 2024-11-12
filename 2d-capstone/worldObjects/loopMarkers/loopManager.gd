extends Node2D

@onready var start = $LoopMarkerStart
@onready var end = $LoopMarkerEnd

var startTime
var enemiesToRespawn = []
var powerupsToRespawn = []
var jumpsToRespawn = []

var loopMax = 3
var loopNum = 0

signal recordData()
signal resetData()
signal recordEnemies(enemyPos)
signal recordPowers(powerPos)

# Called when the node enters the scene tree for the first time.
func _ready():
	recordData.connect(_onRecordData)
	resetData.connect(_onResetData)
	recordEnemies.connect(_onRecordEnemies)
	recordPowers.connect(_onRecordPowers)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _onRecordData():
	#print("Hit start, recording data")
	startTime = Globals.time
	#print("Restart at this time: ", startTime)

func _onResetData(destination):
	print("Resetting my loop")
	loopNum += 1
	if loopNum < loopMax:
		get_tree().root.get_node("level").emit_signal("resetLoop", startTime, destination, enemiesToRespawn, powerupsToRespawn)

func _onRecordEnemies(enemyPos):
	enemiesToRespawn.append(enemyPos)
	#print("Need to respawn: ", enemiesToRespawn)

func _onRecordPowers(powerPos):
	print("Need to respawn: ", powerupsToRespawn)
	powerupsToRespawn.append(powerPos)
