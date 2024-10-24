extends Node2D

var time : float = 0
var bpm: int = 100
var count = 0
@onready var timer

func _ready():
	timer = $Timer
	
# autoscroller manager
func _process(delta: float) -> void:
	updateTime(delta)
	
func updateTime(delta: float):
	time = time + delta
	timer.text = str(round_to_dec(time, 2))
	
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)




	
	
