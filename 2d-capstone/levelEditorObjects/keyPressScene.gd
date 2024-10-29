extends Node2D

var keyFolderPath = "res://ui/assets/onboarding/keys"
var pathToTarget = ""

#images
@onready var punchImage = preload("res://ui/assets/onboarding/punchGraphic.png")
@onready var slideImage = preload("res://ui/assets/slide.webp")
@onready var activateImage = preload("res://ui/assets/onboarding/activateGraphic.png")
@onready var jumpImage = preload("res://ui/assets/onboarding/jumpGraphic.png")

@onready var sprite = $Node2D/Sprite2D
#default
var instructionType = "punch"
# Called when the node enters the scene tree for the first time.

#paths to images so that can display what we are 
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		


func _input(event):
	pass
	#var eventName = event.as_text().to_lower()
	#pathToTarget = keyFolderPath
	#if event is InputEventKey and get_tree().current_scene.currentBlock.index == get_parent().index:
		#var dir = DirAccess.open(keyFolderPath)
		#dir.list_dir_begin()
		#var curFileName = dir.get_next()
		#while curFileName != "":
			#print("cur file name: ", curFileName, " event name: ", eventName)
			#if curFileName == (eventName+".png"):
				#dir.list_dir_end()
				#pathToTarget += "/"+curFileName
				#var newImage = load(pathToTarget)
				#self.get_node("Node2D/Sprite2D").texture = newImage
				##set the size of the image
				#
				#var colShape = get_node("Node2D/EditorArea0/CollisionShape2D").shape as RectangleShape2D
				#var newSize = colShape.extents * 2.0
				#self.get_node("Node2D/Sprite2D").scale = newSize /( self.get_node("Node2D/Sprite2D").texture.get_size()  )
			#curFileName = dir.get_next()
	#if event is InputEventJoypadButton and get_tree().current_scene.currentBlock.index == get_parent().index:
		#pass

func setInstructionType(newInst) -> void:
	match newInst:
		"punch":
			sprite.texture = punchImage
			instructionType = "punch"
		"slide":
			sprite.texture = slideImage
			instructionType = "slide"
		"jump":
			sprite.texture = jumpImage
			instructionType = "jump"
		"activate":
			sprite.texture = activateImage
			instructionType = "activate"
	
func setImage(posPoints):
	if posPoints.size() > 2:
		print("image name: ", posPoints[2])
		setInstructionType(posPoints[2])
		#var newImage = load(posPoints[2])
		#self.get_node("Node2D/Sprite2D").texture = newImage
		##set the size of the image
		#var colShape = get_node("Node2D/EditorArea0/CollisionShape2D").shape as RectangleShape2D
		#var newSize = colShape.extents * 2.0
		#self.get_node("Node2D/Sprite2D").scale = newSize /( self.get_node("Node2D/Sprite2D").texture.get_size()  )
