extends Node2D
var reached = false
var curSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('goals')
	curSprite = get_node("Area2D/Sprite2D").duplicate()
	pass # Replace with function body.



#when both players reach their goal block, the game is ended. 

func getReached() -> bool:
	return reached
	
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("name of body: ", body.name)
	if body.is_in_group("players"):
		print("hit goal block")
		print("entered collsion zone for goal block")
		reached = true
		get_parent().get_parent().emit_signal("checkLevelCompleted")
	pass # Replace with function Sbody.
