extends Node2D

@onready var start = $LoopMarkerStart
@onready var end = $LoopMarkerEnd

var startTime

signal recordData()
signal resetData()

# Called when the node enters the scene tree for the first time.
func _ready():
	recordData.connect(_onRecordData)
	rese
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _onRecordData():
	print("Hit start, recording data")
	startTime = Globals.time
	print("Restart at this time: ", startTime)
