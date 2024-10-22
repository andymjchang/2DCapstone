extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onKeyBindingsButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/keybindings.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/keybindings.tscn")
	else:
		var kbScene = load("res://ui/keybindings.tscn")
		var kbInstance = kbScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(kbInstance)
		self.visible = false

func _onBackButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/pauseScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/landingPage.tscn")
	else:
		get_tree().current_scene.get_node("LevelUI/PauseScreen").visible = true
		self.queue_free()

func _onVolumeButtonUp() -> void:
	#get_tree().change_scene_to_file("res://ui/volumeScreen.tscn")
	var curScene = get_tree().current_scene
	if curScene == self:
		get_tree().change_scene_to_file("res://ui/volumeScreen.tscn")
	else:
		var volumeScene = load("res://ui/volumeScreen.tscn")
		var volumeInstance = volumeScene.instantiate()
		get_tree().current_scene.get_node("LevelUI").add_child(volumeInstance)
		self.visible = false
