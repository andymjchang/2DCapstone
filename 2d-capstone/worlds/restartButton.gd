extends Button

@export var goToScenePath = "res://worlds/menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _onPressed():
	get_tree().change_scene_to_file(goToScenePath)
	pass # Replace with function body.


func _on_restart_button_button_down() -> void:
	pass # Replace with function body.
