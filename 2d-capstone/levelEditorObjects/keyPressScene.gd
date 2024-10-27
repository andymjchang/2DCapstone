extends Node2D

var keyFolderPath = "res://ui/assets/onboarding/keys"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		


func _input(event):
	var eventName = event.as_text()
	var pathToTarget = keyFolderPath
	if event is InputEventKey:# and # get_tree().current_scene.currentBlock.index == get_parent().index:
		var dir = DirAccess.open(keyFolderPath)
		dir.list_dir_begin()
		var curFileName = dir.get_next()
		while curFileName != "":
			print("cur file name: ", curFileName, " event name: ", eventName)
			if curFileName == (eventName+".png"):
				dir.list_dir_end()
				pathToTarget += "/"+curFileName
				var newImage = load(pathToTarget)
				self.get_node("Node2D/Sprite2D").texture = newImage
			curFileName = dir.get_next()
	#if event is InputEventJoypadButton and get_tree().current_scene.currentBlock.index == get_parent().index:
		#pass
		
