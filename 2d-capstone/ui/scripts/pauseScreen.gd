extends Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onResumeButtonUp() -> void:
	#send signal to start everything 
	Engine.time_scale = 1.0
	self.visible = false
	Globals.paused = false
	self.get_parent().get_parent().get_node("Camera2D/Music").stream_paused = false

func _onMainMenuButtonUp() -> void:
	Engine.time_scale = 1.0
	Globals.paused = false
	get_tree().change_scene_to_file("res://ui/landingPage.tscn")


func _onOptionsButtonUp() -> void:
	var optionsScene = load("res://ui/options.tscn")
	var optionsInstance = optionsScene.instantiate()
	print("root, ", get_tree().current_scene)
	get_tree().current_scene.get_node("LevelUI").add_child(optionsInstance)
	self.visible = false
	#TODO find a better way to do this
	#get_tree().change_scene_to_file("res://ui/options.tscn")
