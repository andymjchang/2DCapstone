extends CanvasLayer

@onready var music = $music
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.relocateToCheckpoint = false
	Globals.checkpoint = null
	var audioPath = load("res://audioTracks/MainMenu_115bpm.mp3") as AudioStream
	music.stream = audioPath
	music.play()
	music.stream.loop = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _onStoryButtonPressed():
	Globals.FadeTransition("res://worlds/levelTemplate.tscn")

func _onEditorButtonPressed():
	get_tree().change_scene_to_file("res://levelEditor/levelEditor.tscn")

func _onQuitButtonPressed():
	get_tree().quit()
	
func _onLevelSelectPressed() -> void:
	get_tree().change_scene_to_file("res://ui/levelSelect.tscn")


func _onOptionsButtonPressed() -> void:
	get_tree().change_scene_to_file("res://ui/options.tscn")
