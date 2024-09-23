extends Node2D

@onready var actionIndicatorArray
@onready var currentWorldScene
var current_index = 0
var starting_index = 0

func _ready():
	actionIndicatorArray = get_children()
	actionIndicatorArray.sort_custom(sortIndicators)
	
	for indicator in actionIndicatorArray:
		indicator.connect("scored", on_scored)
	
	currentWorldScene = get_parent().get_parent()
	#print("current world scene: ", currentWorldScene)

func sortIndicators(a, b):
	if a.get_target_time() < b.get_target_time():
		return true
	return false
	
func _process(_delta: float) -> void:
	# check targeted time
	current_index = starting_index
	while current_index < actionIndicatorArray.size():
		var indicator = actionIndicatorArray[current_index]
		current_index += 1
		#print("World time: ", currentWorldScene.time)
		#print("indictor target time: ", indicator.get_target_time())
		if currentWorldScene.time >= indicator.get_target_time():
			indicator.start_transition()
			starting_index += 1 # don't search through here again
		else:
			break
			
func on_scored(indicator_position):
	currentWorldScene.updateScore(indicator_position)
