extends Control

@onready var inputMap = InputMap.get_actions()
@onready var jumpEvents = InputMap.action_get_events("jump")
@onready var slideEvents = InputMap.action_get_events("slide")
@onready var punchEvents = InputMap.action_get_events("punch")
@onready var escapeEvents = InputMap.action_get_events("escape")

#sprites
@onready var shortKey = preload("res://ui/assets/onboarding/keyBackgrounds/key_unpressed.png")
@onready var longKey = preload("res://ui/assets/onboarding/keyBackgrounds/key_long_unpressed.png")

@onready var currentKeyList = $currentKeys
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

var buttonResetting



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setTextBoxes()
	for button in $buttons.get_children():
		button.connect("button_up", _onKeyButtonUp.bind(button.name))
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func resetAllCommands () -> void:
	allCommands = { "jump": InputMap.action_get_events("jump"),
"slide" : InputMap.action_get_events("slide"),
"punch" : InputMap.action_get_events("punch"),
"pause" : InputMap.action_get_events("pause"),
"activate" : InputMap.action_get_events("activate")
}
	
func sortLength(a : String, b : String ):
	if a.length() < b.length():
		return false
	return true

func formatImage(commands) -> String:
	var returnString = "" 
	var keyboardArray = []
	var controllerArray = []
	var keyboardControls = true
	#add in a check for whether or not we are doing controller
	for command in commands:
		#var keyName = OS.get_keycode_string(command.scancode)
		var commandText = command.as_text()
		commandText = commandText.replace("Physical", "")
		commandText = commandText.replace(" ", "")
		commandText = commandText.replace("(", "")
		commandText = commandText.replace(")", "")
		if command.get_class() == "InputEventKey" and keyboardControls:
			keyboardArray.append(str(commandText))
		elif command.get_class() == "InputEventJoypadMotion" and !keyboardControls:
			controllerArray.append(str(commandText))
		elif !keyboardControls:
			controllerArray.append(str(commandText))
	
	#temp solution
	keyboardArray.sort_custom(sortLength)
	if keyboardControls:
		for keyPress in keyboardArray:
			returnString += keyPress
		
	#returnString += "Keyboard: "
	#for keyPress in keyboardArray:
		#returnString += keyPress + ", "
	#returnString += "\nController: "
	#for controllerPress in controllerArray	:
		#returnString += controllerPress + ", "
	return returnString

func _onBackButtonUp() -> void:
	for node in get_tree().get_nodes_in_group("Label"):
		node.deselect()
	buttonResetting = null

func _onKeyButtonUp(name) -> void:
	buttonResetting = self.get_node("buttons/"+name)
	
func _input(event):
	if event is InputEventKey and buttonResetting:
		addCommand(event)
	if event is InputEventJoypadButton and buttonResetting:
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
			print("binding: ", binding.as_text(), " event: ", event.as_text())
			var bindingText = binding.as_text()
			bindingText = bindingText.replace("Physical", "")
			bindingText = bindingText.replace(" ", "")
			bindingText = bindingText.replace("(", "")
			bindingText = bindingText.replace(")", "")
			if bindingText == event.as_text():
				#we have find the same command in another action, swap them
				InputMap.action_erase_event(commandString, event)
				#InputMap.action
				#we need to get the one command in the one we are swapping from
				InputMap.action_add_event(commandString,allCommands[curCommand][0])
				print("command string: ", commandString,allCommands[curCommand])
				setTextBoxes()
				break
	
	#now we are free to add the command in to where we want to 
	
	for command in allCommands[curCommand]:
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
		print("text: ", formatImage(rawText))
		#formatText(rawText)
		#curTextBox.text = formatText(rawText)
		var imageText = formatImage(rawText)
		
		var lengthType = "Short" if imageText.length() < 3 else "Long"
		var notLengthTpe = "Short" if lengthType == "Long" else "Long"
		
		curSprite =  self.get_node("currentKeys/"+str(key)+lengthType+"Current")
		var notCurSprite = self.get_node("currentKeys/"+str(key)+notLengthTpe+"Current")
		curSprite.visible = true
		notCurSprite.visible = false
		
		curSprite.get_node("Label").text = imageText
		
