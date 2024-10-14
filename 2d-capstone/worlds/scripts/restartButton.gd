extends CanvasLayer

@export var goToScenePath = "res://worlds/menu.tscn"
@export var reloadSelf = true

func _on_restart_button_button_down() -> void:
	if reloadSelf:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file(goToScenePath)


func _onCheckpointButtonPressed() -> void:
	get_tree().reload_current_scene()