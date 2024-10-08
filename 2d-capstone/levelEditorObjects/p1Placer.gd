extends Node2D
@onready var lineNode = $Line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#move the second block 
	self.get_node("Player2").global_position.y += 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#dont let the player placer objects get out of line
	print("line pos: ", lineNode.global_position)
	var index = 1
	for placer in self.get_children():
		if placer.name != "Line":
			placer.global_position.x = lineNode.global_position.x
			var editorName = "EditorArea"+str(index)
			index+=1
	Globals.startP1Coords = self.get_node("Player1").global_position
	Globals.startP2Coords = self.get_node("Player2").global_position
