extends MyBaseObject
var reached = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('goals')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#when both players reach their goal block, the game is ended. 

func getReached() -> bool:
	return reached
	
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if body.is_in_group("players"):
		print("entered collsion zone for goal block")
		reached = true
		get_parent().get_parent().emit_signal("checkLevelCompleted")
	pass # Replace with function Sbody.
