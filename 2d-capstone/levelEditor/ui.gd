extends CanvasLayer

@onready var helpWindow = $HelpWindow
@onready var desc = $HelpWindow/Description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_level_button_mouse_entered():
	helpWindow.position = getPosition($FileButtons/playLevelButton)
	helpWindow.show()
	desc.text = "Plays the level"
	print("Play button entered")


func _on_button_exited() -> void:
	helpWindow.hide()
	pass # Replace with function body.

func getPosition(tgt):
	if tgt.global_position.y <= get_viewport().size.y/2:
		print("Upper half")
		return tgt.global_position + Vector2(0, 100)
	print("Lower half")
	return tgt.global_position - Vector2(0, 100)


func _on_save_button_mouse_entered() -> void:
	helpWindow.position = getPosition($FileButtons/playLevelButton)
	helpWindow.show()
	desc.text = "Saves the level's data to its file"
	print("Play button entered")
