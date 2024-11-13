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
	$storyButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#TODO add  this back in for controller at a lter date
#func _unhandled_input(event):
	#if event.is_action_pressed("ui_accept"):  # Typically mapped to the "A" button or "Enter"
		#if Globals.usingController:
			#$storyButton.emit_signal("pressed")

#func _input(event: InputEvent) -> void:
	##check to see whether or not the user has switched to keyboard or controller
	#print("event calss: ", event.get_class())
	#
	#if event.get_class() == "InputEventJoypadButton" or event.get_class() == "InputEventJoypadMotion":
		##player is using controller
		#print("making to controlle detction")
		#Globals.usingController = true
	#else:
		##player is not using controller
		#print("not making it to contolle dection, well not bad but liek its detcting akey idl")
		#Globals.usingController = false
func _onStoryButtonPressed():
	Globals.FadeTransition("res://worlds/levelTemplate.tscn")

func _onEditorButtonPressed():
	# get_tree().change_scene_to_file("res://levelEditor/levelEditor.tscn")
	Globals.FadeTransition("res://levelEditor/levelEditor.tscn")

func _onQuitButtonPressed():
	get_tree().quit()
	
func _onLevelSelectPressed() -> void:
	get_tree().change_scene_to_file("res://ui/levelSelect.tscn")
	


func _onOptionsButtonPressed() -> void:
	Globals.FadeTransition("res://ui/options.tscn")
