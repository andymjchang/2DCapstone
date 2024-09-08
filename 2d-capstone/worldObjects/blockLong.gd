extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var randPlatform = "Platform" + str(randi_range(1, 2))
	get_node(randPlatform).visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
