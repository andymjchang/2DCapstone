extends Node2D

var time : float = 0
var bpm: int = 100
var score = 0

@onready var timerText
@onready var player
@onready var camera
@onready var scoreText

var textPopupScene = preload("res://worldObjects/scoreText.tscn")

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
	
func updateScore(indicator_position):
	var score_to_add = 100 - (indicator_position - player.position.x)
	print("indicator pos" + str(indicator_position))
	print("player pos" + str(player.position.x))
	score += score_to_add
	scoreText.text = str(int(score))
	var textPopup = textPopupScene.instantiate()
	textPopup.initText(score_to_add, player.position)
	add_child(textPopup)
	
	
#func updateCameraPosition():
	#camera.position.x = player.position.x
	
