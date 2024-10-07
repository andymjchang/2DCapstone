extends Node2D
@onready var lineNode = $Line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#dont let the player placer objects get out of line
	for placer in self.get_children():
		if placer.name != "Line":
			#placer.global_position.x = lineNode.global_position.x
			print("placer global pos: ", placer.global_position, " name: ", placer.name)
