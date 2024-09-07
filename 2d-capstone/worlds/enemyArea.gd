extends Area2D



# when player runs into an enemy, the enemy dissapears
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Enemy ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_Area2D_body_entered(body) -> void :
	print("Body entered: ", body)
