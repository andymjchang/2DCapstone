extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.curFile == "Level 1" or Globals.curFile.begins_with("Tutorial"):
		self.visible = true
	else:
		self.visible = false
