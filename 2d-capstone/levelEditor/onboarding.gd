extends CanvasLayer

var curStep = 0

@onready var status = $VBoxContainer/StatusMessage

var instructionText = {
	0: "\nWelcome to the level editor! Let's go through the basics.",
	1: "\nTo add items to the editor, click on the buttons below!",
	2: "If you are unsure about what a button does, mouse over it for a brief description."
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_button_pressed() -> void:
	curStep += 1
	if curStep >= instructionText.size():
		print("end of tutortial reached, ending")
		curStep = 0
		hide()
	else:
		status.text = instructionText[curStep]
