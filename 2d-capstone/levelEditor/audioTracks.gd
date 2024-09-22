extends ScrollContainer
var button
var scrollBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fillAudioScroll()
	scrollBar = $VScrollBar
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func addButton(fileName) -> void:
	print("delete this idk")
	
func fillAudioScroll() -> void:
	var audioDirPath = "res://audioTracks"
	var audioDir = DirAccess.open(audioDirPath)
	var dropDown = self.get_node("UI/objectSelector/audioTracks")
	if(audioDir):
		audioDir.list_dir_begin()
		var file_name = audioDir.get_next()
		while file_name != "":
			#add audio file to drop down
			button = Button.new()
			button.text = file_name
			self.get_child(0).add_child(button)
			file_name = audioDir.get_next()
			
	
