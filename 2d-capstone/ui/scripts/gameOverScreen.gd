extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _onRetryButtonUp() -> void:
	Globals.relocateToCheckpoint = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _onMenuButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://ui/landingPage.tscn")

func _onCheckpointButtonDown() -> void:
	Globals.relocateToCheckpoint = true
	Globals.inLevel = false


func _onCheckpointButtonUp() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
