extends Node2D

var time : float = 0
var bpm: int = 100
var score = 0
@onready var timerText
@onready var player
@onready var camera
@onready var scoreText

func _ready():
	timerText = $CanvasLayer/Timer
	player = $Player
	camera = $Camera2D
	scoreText = $CanvasLayer/Score
	
# autoscroller manager
func _process(delta: float) -> void:
	updateTime(delta)
	
func updateTime(delta: float):
	time = time + delta
	timerText.text = str(round_to_dec(time, 2))
	
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func updateScore():
	score += 100
	scoreText.text = str(score)
	
	
#func updateCameraPosition():
	#camera.position.x = player.position.x
	
