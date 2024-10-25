extends Node2D

var actionIndicatorLocations = []
var index = 0.0

@onready var enemy = $Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.isMultiPunch = true
	enemy.punchesLeft = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func moveToNext() -> void:
	enemy.global_position = actionIndicatorLocations[index]
	index+=1
