extends Node2D
signal playerspotted

var count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("HIII")



func _on_area_2d_body_entered(body: Node2D) -> void:
	count = count + 1
	print("count: ", count)
	#WHHYYYY
	if count >= 1:
		self.visible = false
		print("HIII")
