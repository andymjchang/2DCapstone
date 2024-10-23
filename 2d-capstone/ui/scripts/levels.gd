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
	var levelsDirPath = "res://levelData"
	var levelDir = DirAccess.open(levelsDirPath)
	if(levelDir):
		levelDir.list_dir_begin()
		var fileName = levelDir.get_next()
		while fileName != "":
			#add audio file to drop down
			button = Button.new()
			button.text = fileName.trim_suffix(".dat")
			button.connect("pressed", _on_button_pressed.bind(fileName.trim_suffix(".dat")))
			self.get_child(0).add_child(button)
			
			fileName = levelDir.get_next()
			
			
func _on_button_pressed(fileName) -> void:
	Globals.curFile = fileName
	Globals.FadeTransition("res://worlds/levelTemplate.tscn")
			
	
