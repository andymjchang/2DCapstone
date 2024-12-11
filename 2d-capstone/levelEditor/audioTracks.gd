extends ScrollContainer
var button
var scrollBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open("user://")
	dir.make_dir("editorAudio")
	for buttonChild in get_child(0).get_children():
		if "Button" in buttonChild.name:
			buttonChild.connect("pressed", _on_button_pressed.bind(buttonChild.text))
	fillAudioScroll()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func fillAudioScroll() -> void:
	var audioDirPath = "user://editorAudio/"
	var audioDir = DirAccess.open(audioDirPath)
	if(audioDir):
		audioDir.list_dir_begin()
		var fileName = audioDir.get_next()
		while fileName != "":
			#print("File from user: ", fileName)
			#add audio file to drop down
			if !fileName.ends_with(".import") and !audioDir.current_is_dir():
				button = Button.new()
				button.text = fileName
				button.connect("pressed", _on_button_pressedUSER.bind(fileName))
				self.get_child(0).add_child(button)
			
			fileName = audioDir.get_next()
			
			
func _on_button_pressed(fileName) -> void:
	Globals.currentSongFileName = fileName
	var audioPath = "res://editorAudio/" + fileName
	var newAudio = load(audioPath) as AudioStream
	#print("audio path: ", audioPath)
	#print("new audio: ", newAudio)
	self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream = newAudio
	#print("stream: ", self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream )
			
func _on_button_pressedUSER(fileName) -> void:
	Globals.currentSongFileName = fileName
	var audioPath = "user://editorAudio/" + fileName
	var file = FileAccess.open(audioPath, FileAccess.READ)
	#print("File opened: ", file)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream = sound
	#print("stream: ", self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream )
			
