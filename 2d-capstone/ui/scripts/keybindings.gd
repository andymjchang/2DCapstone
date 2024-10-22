extends Control

@onready var inputMap = InputMap.get_actions()
@onready var jumpEvents = InputMap.action_get_events("jump")
@onready var slideEvents = InputMap.action_get_events("slide")
@onready var punchEvents = InputMap.action_get_events("punch")
@onready var escapeEvents = InputMap.action_get_events("escape")

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
$buttons/activateKey: [$currentKeys/activateCurrent, "activate"],
$buttons/pauseKey: [$currentKeys/pauseCurrent, "pause"]
}

var buttonResetting



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setTextBoxes()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func formatText(commands) -> String:
	var returnString = "" 
	var keyboardString = ""
	var controllerString = ""
	for command in commands:
		#var keyName = OS.get_keycode_string(command.scancode)
		if command.get_class() == "InputEventKey":
			#keyboardString += OS.get_keycode_string(command.physical_keycode)+", "
			keyboardString += command.as_text()+", "
		elif command.get_class() == "InputEventJoypadMotion":
			controllerString+=command.as_text()+", "
		else:
			controllerString+=command.as_text()+", "
			
	returnString += "Keyboard: "+keyboardString+"\n"+"Controller: "+controllerString
	return returnString

func _onBackButtonUp() -> void:
	#TODO make a stack of scens so that we can go back to the calling sce
	get_tree().change_scene_to_file("res://ui/options.tscn")

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
	
	
	#check to see if command already exists, if so do nothing
	for binding in allBindings:
		if binding.as_text() == event.as_text():
			return false
			
	#check to see if it exists in other places - if so delete
	for commandKey in nodePairs.keys():
		var curCommandPair = nodePairs[commandKey]
		var commandString = curCommandPair[1]
		
		for binding in allCommands[commandString]:
			if binding.as_text() == event.as_text():
				#we have find the same command in another action, delete
				InputMap.action_erase_event(commandString, event)
				setTextBoxes()
				break
	
	#now we are free to add the command in to where we want to 
	InputMap.action_add_event(curCommand, event)
	setTextBoxes()
	#we should retrigger the text formatter
	return true
	
func setTextBoxes() -> void:
	allCommands = { "jump": InputMap.action_get_events("jump"),
	"slide" : InputMap.action_get_events("slide"),
	"punch" : InputMap.action_get_events("punch"),
	"pause" : InputMap.action_get_events("pause"),
		"activate" : InputMap.action_get_events("activate")
	}
	for button in $buttons.get_children():
			#newArea.connect("input_event",  _on_area_2d_input_event.bind(newArea.name, blockChild))
		button.connect("button_up", _onKeyButtonUp.bind(button.name))
	var curTextBox
	for key in allCommands.keys():
		curTextBox =  self.get_node("currentKeys/"+str(key)+"Current")
		var rawText = allCommands[key]
		formatText(rawText)
		curTextBox.text = formatText(rawText)
