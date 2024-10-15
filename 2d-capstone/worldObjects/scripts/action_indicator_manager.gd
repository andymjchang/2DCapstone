extends Node2D

@onready var actionIndicatorArray
@onready var currentWorldScene
var current_index = 0
var starting_index = 0

func load_array():
	actionIndicatorArray = get_tree().get_nodes_in_group("actionIndicators")
	for indicator in actionIndicatorArray:
		indicator.initialize()
	actionIndicatorArray.sort_custom(sortIndicators)
	currentWorldScene = get_parent().get_parent()
	

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
		if currentWorldScene.time >= indicator.get_target_time():
			#print("current time" + str(currentWorldScene.time))
			indicator.start_transition()
			starting_index += 1 # don't search through here again
		else:
			break
			
