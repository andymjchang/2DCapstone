extends CanvasLayer

var curStep = 0

@onready var status = $VBoxContainer/StatusMessage

var instructionText = {
	0: "\nWelcome to the level editor! Let's go through the basics.",
	1: "\nTo add items to the editor, click on the buttons below!",
	2: "If you are unsure about what a button does, mouse over it for a brief description.",
	3: "\nTo start making a level, first click the file button above!",
	4: "\nEnter a name and click load. If the file exists, it'll load the file data.",
	5: "Make sure you enter the BPM of the song you're editing into the text box in the upper left!",
	6: "Red lines signify measures. Green lines signify beats between each measure.",
	7: "Beats per measure changes the number of green lines that appear between measures.",
	8: "Step size changes the size of the grid. The smaller the number, the smaller the grid.",
	9: "To set the song you want to make the level with, use the song menu below!",
	10: "You can also preview the song from within the editor using the audio play button.",
	11: "You can move objects by clicking and dragging, or using the arrow keys below!",
	12: "The editor also features a few handy keyboard shortcuts. Click the keys button to see them.",
	13: "\nTo play your level, click the play button! Have fun!"
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
		status.text = instructionText[curStep]
		hide()
	else:
		status.text = instructionText[curStep]

func _on_exit_button_pressed():
	curStep = 0
	status.text = instructionText[curStep]
	hide()
	pass # Replace with function body.
