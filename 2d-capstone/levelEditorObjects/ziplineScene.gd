extends Node2D
enum {START, END}

var startPlaced = false
var endPlaced = false

#scale 0.25
#inhereits click and drag functionality from 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_node("End").global_position.x += 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
