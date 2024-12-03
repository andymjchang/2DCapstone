extends Node2D

@onready var start = $LoopMarkerStart
@onready var end = $LoopMarkerEnd

enum {START, END}

var startTime
var enemiesToRespawn = []
var powerupsToRespawn = []
var jumpsToRespawn = []
var firstPass = true

var enemiesToDespawn = []
var powerupsToDespawn = []

var loopMax = 3
var loopNum = 0

signal recordData()
signal resetData()
signal recordEnemies(enemyPos)
signal recordPowers(powerPos)

# Called when the node enters the scene tree for the first time.
func _init():
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
	if loopNum <= loopMax:
		for enemy in enemiesToDespawn:
			enemy.queue_free()
		for power in powerupsToDespawn:
			power.queue_free()
		enemiesToDespawn = []
		powerupsToDespawn = []
		get_tree().root.get_node("level").emit_signal("resetLoop", startTime, destination, enemiesToRespawn, powerupsToRespawn)

func _onRecordEnemies(enemy):
	if firstPass:
		enemiesToRespawn.append(enemy.global_position)
	#print("Need to respawn: ", enemiesToRespawn)
	enemiesToDespawn.append(enemy)

func _onRecordPowers(power):
	print("Need to respawn: ", powerupsToRespawn)
	if firstPass:
		powerupsToRespawn.append(power.global_position)
	powerupsToDespawn.append(power)
