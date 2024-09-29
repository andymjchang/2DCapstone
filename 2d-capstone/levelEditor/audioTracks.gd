extends ScrollContainer
var button
var scrollBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fillAudioScroll()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func fillAudioScroll() -> void:
	var audioDirPath = "res://audioTracks"
	var audioDir = DirAccess.open(audioDirPath)
	if(audioDir):
		audioDir.list_dir_begin()
		var fileName = audioDir.get_next()
		while fileName != "":
			#add audio file to drop down
			if !fileName.ends_with(".import") and !audioDir.current_is_dir():
				button = Button.new()
				button.text = fileName
				button.connect("pressed", _on_button_pressed.bind(fileName))
				self.get_child(0).add_child(button)
			
			fileName = audioDir.get_next()
			
			
func _on_button_pressed(fileName) -> void:
	Globals.currentSongFileName = fileName
	var audioPath = "res://audioTracks/" + fileName
	var newAudio = load(audioPath) as AudioStream
	print("audio path: ", audioPath)
	print("new audio: ", newAudio)
	self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream = newAudio
	print("stream: ", self.get_parent().get_parent().get_parent().get_node("Camera2D/audio").stream )
			
	
