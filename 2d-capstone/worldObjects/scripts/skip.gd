extends Node2D


var tgtTime = 0.0
var isActivated
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("skips")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#check to see if global time has activated if so display skip thing, give user 5 seconds to skip
	
	pass
	
func _load(time) -> void:
	pass

func getTgtTime() -> float:
	return tgtTime
	
	
