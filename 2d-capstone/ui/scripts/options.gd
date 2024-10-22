extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onKeyBindingsButtonUp() -> void:
	get_tree().change_scene_to_file("res://ui/keybindings.tscn")



func _onBackButtonUp() -> void:
	get_tree().change_scene_to_file("res://ui/pauseScreen.tscn")
