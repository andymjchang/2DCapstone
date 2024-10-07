extends Node

var ziplineArea
var ziplineContainer
enum {START, END}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ziplineArea = $ziplineArea
	ziplineContainer = self.get_parent()
	ziplineArea.body_entered.connect(_onBodyEntered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _onBodyEntered(body):
	print("Entering body: ", body.name)
	if "Player" in body.name:
		if self.name == "ziplineStart":
			# print("My end: ", get_parent().get_child(END))
			var otherPlayer = get_tree().root.get_node("level").get_node("objectList").get_node("players").get_node("Player2")
			otherPlayer.position.x = body.position.x
			var destination = get_parent().get_child(END)
			var newVelocity = (destination.position - body.position) / 2
			body.velocity = newVelocity
			body.inZipline = true
			body.relocating = true

			otherPlayer.velocity = newVelocity
			otherPlayer.inZipline = true
			otherPlayer.relocating = true

		elif self.name == "ziplineEnd" and body.inZipline:
			print("at end")
			body.inZipline = false
			body.relocating = false
			body.velocity = Vector2(0, 0)

	pass
