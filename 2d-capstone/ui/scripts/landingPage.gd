extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _onStoryButtonPressed():
	get_tree().change_scene_to_file("res://worlds/levelTemplate.tscn")

func _onEditorButtonPressed():
	get_tree().change_scene_to_file("res://levelEditor/levelEditor.tscn")

func _onQuitButtonPressed():
	get_tree().quit()
	
func _onLevelSelectPressed() -> void:
	get_tree().change_scene_to_file("res://ui/levelSelect.tscn")
