extends Control

@onready var inputMap = InputMap.get_actions()
@onready var jumpEvents = InputMap.action_get_events("jump")
@onready var slideEvents = InputMap.action_get_events("slide")
@onready var punchEvents = InputMap.action_get_events("punch")
@onready var escapeEvents = InputMap.action_get_events("escape")

#sprites
@onready var shortKey = preload("res://ui/assets/onboarding/keyBackgrounds/key_unpressed.png")
@onready var longKey = preload("res://ui/assets/onboarding/keyBackgrounds/key_long_unpressed.png")

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

@onready var currentKeyList = $currentKeys


#data structures

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
	
	
@onready var allCommands = { "jump": InputMap.action_get_events("jump"),
"slide" : InputMap.action_get_events("slide"),
"punch" : InputMap.action_get_events("punch"),
"pause" : InputMap.action_get_events("pause"),
"activate" : InputMap.action_get_events("activate")
}


@onready var nodePairs = {$buttons/jumpKey: [$currentKeys/jumpCurrent, "jump"],
$buttons/slideKey: [$currentKeys/slideCurrent, "slide"],
$buttons/punchKey: [$currentKeys/punchCurrent,"punch" ],
}

#controller sprites
@onready var punchC = $currentKeys/punchController
@onready var jumpC = $currentKeys/jumpController
@onready var slideC = $currentKeys/slideController

var buttonResetting




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setTextBoxes()
	for button in $buttons.get_children():
		button.connect("button_up", _onKeyButtonUp.bind(button.name))
		button.focus_mode = Control.FOCUS_NONE
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func controllerNavigate(val):
	if val:
		$buttons/jumpKey.grab_focus()
	
func sortLength(a : String, b : String ):
	if a.length() < b.length():
		return false
	return true

func formatImage(commands) -> String:
	var returnString = "" 
	var keyboardArray = []
	var contArray = []
	var keyboardControls = true
	#add in a check for whether or not we are doing controller
	for command in commands:
		#var keyName = OS.get_keycode_string(command.scancode)
		var commandText = command.as_text()
		commandText = commandText.replace("Physical", "")
		commandText = commandText.replace(" ", "")
		commandText = commandText.replace("(", "")
		commandText = commandText.replace(")", "")
		if command.get_class() == "InputEventKey":
			keyboardArray.append(str(commandText))
		elif command.get_class() == "InputEventJoypadMotion":
			print("joypoy motion: ", command.as_text())
			contArray.append(str(command.as_text()))
		elif command.get_class() != "InputEventKey":
			print("joypoy motion: ", command.as_text())
			contArray.append(str(command.as_text()))
			print("joypoy not motion: ", command.as_text())
	
	#temp solution
	keyboardArray.sort_custom(sortLength)
	if !Globals.usingController:
		for keyPress in keyboardArray:
			returnString += keyPress
	elif Globals.usingController:
		for controllerPress in contArray:
			returnString += controllerPress
	return returnString

func _onBackButtonUp() -> void:
	for node in get_tree().get_nodes_in_group("Label"):
		node.deselect()
	buttonResetting = null
	self.get_parent().emit_signal("keybindSet", true)

func _onKeyButtonUp(name) -> void:
	buttonResetting = self.get_node("buttons/"+name)
	self.get_parent().emit_signal("keybindSet", false)
	
func _input(event):
	if event is InputEventKey and buttonResetting:
		print("EVENT BEING PRESSED: ",event.as_text())
		addCommand(event)
	if event is InputEventJoypadButton and buttonResetting:
		print("EVENT BEING PRESSED: ",event.as_text())
		addCommand(event)
		

#returns true if succesfully added, false if similiar binding exists
func addCommand(event) -> bool:
	#I need to grab the current text box
	var curText = nodePairs[buttonResetting][0]
	var curCommand = nodePairs[buttonResetting][1]
	var allBindings = allCommands[curCommand]
	var newEvent = event.as_text()
	
	print("test: ", curText, ", ", curCommand)
	var singularBinding
	#check to see if command already exists, if so do nothing
	for binding in allBindings:
		singularBinding = binding
		if binding.as_text() == event.as_text():
			return false
			
	var swapAction = event
	print("EVENT! ", event)
	#check to see if it exists in other places - if so swap
	for commandKey in nodePairs.keys():
		var curCommandPair = nodePairs[commandKey]
		var commandString = curCommandPair[1]
		print("command string: ", commandString)
		for binding in allCommands[commandString]:
		#	print("binding: ", binding.as_text(), " event: ", event.as_text())
			var bindingText = binding.as_text()
			bindingText = bindingText.replace("Physical", "")
			if !Globals.usingController:
				bindingText = bindingText.replace(" ", "")
				bindingText = bindingText.replace("(", "")
				bindingText = bindingText.replace(")", "")
			print("binding text: ", bindingText, " event text: ",event.as_text())
			if bindingText == event.as_text() and !Globals.usingController:
				#we have find the same command in another action, swap them
				InputMap.action_erase_event(commandString, event)
				#InputMap.action
				#we need to get the one command in the one we are swapping from
				InputMap.action_add_event(commandString,allCommands[curCommand][0])
				print("command string: ", commandString,allCommands[curCommand])
				setTextBoxes()
				break
			elif event.as_text() in bindingText and Globals.usingController:
				print("we are swapping controller")
				
				print("we are erasing commandString: ", commandString, " event: ",event)
				InputMap.action_erase_event(commandString, event)
				#InputMap.action
				#we need to get the one command in the one we are swapping from
				if allCommands[curCommand].size() > 1 and Globals.usingController:
					InputMap.action_add_event(commandString,allCommands[curCommand][1])
				else:
					InputMap.action_add_event(commandString,allCommands[curCommand][0])
				print("command string: ", commandString,allCommands[curCommand])
				setTextBoxes()
				break
			
	#now we are free to add the command in to where we want to 
	
	for command in allCommands[curCommand]:
		print("we are erasing curCommand: ", curCommand, " command: ",command)
		InputMap.action_erase_event(curCommand,command)
		
	InputMap.action_add_event(curCommand, event)
	setTextBoxes()
	#we should retrigger the text formatter
	return true
	
func setTextBoxes() -> void:
	allCommands = { "jump": InputMap.action_get_events("jump"),
	"slide" : InputMap.action_get_events("slide"),
	"punch" : InputMap.action_get_events("punch"),
	}
	
	#for button in $buttons.get_children():
		#button.connect("button_up", _onKeyButtonUp.bind(button.name))
	var curSprite
	for key in allCommands.keys():
		var rawText = allCommands[key]
		#print("text: ", formatImage(rawText))
		var imageText = formatImage(rawText)
		var lengthType = "Short" if imageText.length() < 3 else "Long"
		var notLengthTpe = "Short" if lengthType == "Long" else "Long"
		
		curSprite =  self.get_node("currentKeys/"+str(key)+lengthType+"Current")
		var notCurSprite = self.get_node("currentKeys/"+str(key)+notLengthTpe+"Current")
		
		if Globals.usingController:
			curSprite.visible = false
			notCurSprite.visible = false
			curSprite = self.get_node("currentKeys/"+str(key)+"Controller")
			#print("controller name: ", event.as_text())
			
			var eventText = imageText
			for control in controllerArray:
				if control in (imageText) and (("Axis" in control and "Axis" in imageText) or ("Axis" not in control and "Axis" not in imageText)):
					print("control: ", control, " event text:", eventText)
					var newImage = controllerMap[control]
					print("new Image: ", newImage)
					curSprite.texture = newImage
					print("file path: ", curSprite.texture.resource_path)
					break
			
			
		else:
			curSprite.visible = true
			notCurSprite.visible = false
			curSprite.get_node("Label").text = imageText
			punchC.visible = false
			slideC.visible = false
			jumpC.visible = false
			
		
		
		
