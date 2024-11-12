extends Node2D
var reached = false
var curSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('goals')

#when both players reach their goal block, the game is ended. 

func getReached() -> bool:
	return reached
	
func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("players"):
		print("hit goal block")
		print("entered collsion zone for goal block")
		reached = true
		get_parent().get_parent().get_parent().emit_signal("checkLevelCompleted")
