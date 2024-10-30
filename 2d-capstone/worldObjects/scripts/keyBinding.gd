extends Node2D

var pathToImage = ""
var imageName = ""
var instType = ""
@onready var sprite = $Sprite2D

@onready var punchImage = preload("res://ui/assets/onboarding/punchGraphic.png")
@onready var slideImage = preload("res://ui/assets/slide.webp")
@onready var activateImage = preload("res://ui/assets/onboarding/activateGraphic.png")
@onready var jumpImage = preload("res://ui/assets/onboarding/jumpGraphic.png")

var keyFolderPath = "res://ui/assets/onboarding/keys"
var pathToTarget = ""

@onready var allCommands = { "jump": InputMap.action_get_events("jump"),
"slide" : InputMap.action_get_events("slide"),
"punch" : InputMap.action_get_events("punch"),
"pause" : InputMap.action_get_events("pause"),
"activate" : InputMap.action_get_events("activate")
}
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setKeyBindingImages():
	
	pathToTarget = keyFolderPath
	
	allCommands = { "jump": InputMap.action_get_events("jump"),
	"slide" : InputMap.action_get_events("slide"),
	"punch" : InputMap.action_get_events("punch"),
	"pause" : InputMap.action_get_events("pause"),
	"activate" : InputMap.action_get_events("activate")
	}
	var eventBinds = allCommands[instType]
	#looping through all the events
	for event in eventBinds:
			event = event.as_text().to_lower()
			event = event.replace("physical", "")
			event = event.replace(" ", "")
			event = event.replace("(", "")
			event = event.replace(")", "")
			var dir = DirAccess.open(keyFolderPath)
			dir.list_dir_begin()
			var curFileName = dir.get_next()
			#I do not think I need to loop here
			while curFileName != "":
				if curFileName == (event+".png"):
					dir.list_dir_end()
					pathToTarget += "/"+curFileName
					var newImage = load(pathToTarget)
					self.get_node("Sprite2D").texture = newImage
				curFileName = dir.get_next()
func setImage(posPoints : Array) -> void:
	if posPoints.size() > 2.0:
		var instructionType = posPoints[2]
		instType = instructionType
		setKeyBindingImages()
