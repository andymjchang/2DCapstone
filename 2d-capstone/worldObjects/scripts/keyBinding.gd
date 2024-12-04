extends Node2D

var pathToImage = ""
var imageName = ""
var instType = ""
@onready var sprite = $controllerSprite
@onready var keyName = $keyName

#sprites
@onready var pressedLong = $LongPressed
@onready var pressedShort = $ShortPressed
@onready var unpressedLong = $LongUnpressed
@onready var unpressedShort = $ShortUnpressed

var pressedSprite : Sprite2D
var unpressedSprite : Sprite2D
var watchEvent

#load controller images
var aController = preload("res://ui/assets/onboarding/keys/a_xbox.png")
var bController = preload("res://ui/assets/onboarding/keys/b_xbox.png")
var dPadDownController = preload("res://ui/assets/onboarding/keys/down_xbox.png")
var LBController = preload("res://ui/assets/onboarding/keys/LB_xbox.png")
var leftMidController = preload("res://ui/assets/onboarding/keys/left_mid_button_xbox.png")
var dPadLeftController = preload("res://ui/assets/onboarding/keys/left_xbox.png")
var LSController = preload("res://ui/assets/onboarding/keys/LS_xbox.png")
var LTController = preload("res://ui/assets/onboarding/keys/LT_xbox.png")
var RBController = preload("res://ui/assets/onboarding/keys/RB_xbox.png")
var rightMidController = preload("res://ui/assets/onboarding/keys/right_mid_button_xbox.png")
var dPadRightController = preload("res://ui/assets/onboarding/keys/right_xbox.png")
var RSController = preload("res://ui/assets/onboarding/keys/RS_xbox.png")
var RTController = preload("res://ui/assets/onboarding/keys/RT_xbox.png")
var dPadUpController = preload("res://ui/assets/onboarding/keys/up_xbox.png")
var xController = preload("res://ui/assets/onboarding/keys/x_xbox.png")
var yController = preload("res://ui/assets/onboarding/keys/y_xbox.png")


@onready var punchImage = preload("res://ui/assets/onboarding/punchGraphic.png")
@onready var slideImage = preload("res://ui/assets/slide.webp")
@onready var activateImage = preload("res://ui/assets/onboarding/activateGraphic.png")
@onready var jumpImage = preload("res://ui/assets/onboarding/jumpGraphic.png")

var controllerArray = ["Joypad Button 0 ", "Joypad Button 1 ", "Joypad Button 2 ", "Joypad Button 3 ", "Joypad Button 4 ", "Joypad Motion on Axis 1", "Joypad Button 6 ", "Joypad Button 7 ", "Joypad Button 8 ",  "Joypad Button 9 ", "Joypad Button 10", "Joypad Button 11 ", "Joypad Button 12 ", "Joypad Button 13 ", "Joypad Button 14 ", "Joypad Button 15 ", "Joypad Button 16 ", "Joypad Button 17 ", "Joypad Button 18 ",  "Joypad Button 19 "  , "Joypad Button 20 ", "Joypad Button 21 ", "Joypad Button 22 ",  "Joypad Button 23 "  ]
@onready var controllerMap = {controllerArray[0]: aController,
							controllerArray[1]: bController,
							controllerArray[2]: xController,
							controllerArray[3]: yController,
							controllerArray[4]: LBController,
							controllerArray[5]: LSController,
							controllerArray[6]: LSController,
							controllerArray[7]: LSController,
							controllerArray[8]: RSController, #back/select
							controllerArray[9]: LTController, #start option
							controllerArray[10]: RTController,
							controllerArray[11]: dPadUpController,
							controllerArray[12]: dPadDownController,
							controllerArray[13]: dPadLeftController,
							controllerArray[14]: dPadRightController,
							controllerArray[15]: dPadLeftController,
							controllerArray[16]: aController, #the rest of these are axis contols, do later
							controllerArray[17]: aController,
							controllerArray[18]: aController,
							controllerArray[19]: aController,
							controllerArray[20]: aController,
							controllerArray[21]: aController,	
							controllerArray[22]: aController,
							controllerArray[23]: aController
							}

#grab all of the controller images


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
	if instType and Input.is_action_just_pressed(instType):
		#grey out our image
		if Globals.usingController:
			sprite.modulate = Color(0.5, 0.5, 0.5)
		else:
			pressedSprite.visible = true
			unpressedSprite.visible = false
			#
			#$ColorRect.modulate = Color(0.5, 0.5, 0.5)
	if instType and Input.is_action_just_released(instType):
		if Globals.usingController:
			sprite.modulate = Color(1.0,1.0,1.0)
		else:
			pressedSprite.visible = false
			unpressedSprite.visible = true
	
func controllerNavigate(val):
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
	var keyArray = []
	for event in eventBinds:
		print("event kind: ", event)
		if event.get_class() != "InputEventJoypadButton" and event.get_class() != "InputEventJoypadMotion" and !Globals.usingController:
			var eventText = event.as_text().to_lower()
			eventText = eventText.replace("physical", "")
			eventText = eventText.replace(" ", "")
			eventText = eventText.replace("(", "")
			eventText = eventText.replace(")", "")
			keyArray.append(str(eventText))
			#"[center]Centered Text[/center]
			#keyName.text = "[center]"+str(eventText).to_upper()+"[/center]"
			#sprite.visible = false
			#$ColorRect.visible = true
			#keyName.visible = true
		elif Globals.usingController:
			print("controller name: ", event.as_text())
			
			var eventText = event.as_text()
			for control in controllerArray:
				print("control: ", control, " event text:", eventText)
				if control in (eventText):
					var newImage = controllerMap[control]
					print("new Image: ", newImage)
					sprite.texture = newImage
					pressedLong = false
					unpressedLong.visible = false
					break
					
		if keyArray.size() > 0:
			keyArray.sort_custom(sortLength)
			#"[center]Centered Text[/center]
			#keyName.text = "[center]"+str(keyArray[0]).to_upper()+"[/center]"
			
			var keyText = keyArray[0]
			if keyText.length() > 2:
				pressedSprite = pressedLong
				unpressedSprite = unpressedLong
				unpressedSprite.visible = true
				pressedSprite.visible = false
				pressedShort.visible = false
				unpressedShort.visible = false
				
			else:
				pressedSprite = pressedShort
				unpressedSprite = unpressedShort
				unpressedSprite.visible = true
				pressedSprite.visible = false
				pressedLong.visible = false
				unpressedLong.visible = false
				
			pressedSprite.get_node("Label").text = keyText
			unpressedSprite.get_node("Label").text = keyText
			#sprite.visible = false
			#$ColorRect.visible = true
			#keyName.visible = true
					
					
					
			#print("Event im matching too: ", event)
			#var dir = DirAccess.open(keyFolderPath)
			#dir.list_dir_begin()
			#var curFileName = dir.get_next()
			##I do not think I need to loop here
			#while curFileName != "":
				#if curFileName == (eventText+".png") and event is InputEventKey:
					#dir.list_dir_end()
					#print("Matching file name: ", curFileName)
					#pathToTarget = keyFolderPath
					#pathToTarget += "/"+curFileName
					#print("path to target: ", pathToTarget)
					#var newImage = load(pathToTarget)
					#self.get_node("Sprite2D").texture = newImage
					#watchEvent = eventText
					#print("watch event: ", watchEvent)
					#break
				#curFileName = dir.get_next()
	
func sortLength(a : String, b : String ):
	if a.length() < b.length():
		return false
	return true
					
func setImage(posPoints : Array) -> void:
	if posPoints.size() > 2.0:
		var instructionType = posPoints[2]
		instType = instructionType
		setKeyBindingImages()
		stretchImage()
		
func stretchImage() -> void:
	pass
	#var spriteSize = sprite.texture.get_size()
	#var curExtents = $Area2D/CollisionShape2D.shape.extents
	#var newSize = curExtents * 2.0
	#var newScale = newSize/spriteSize
	#sprite.scale = newScale
	
