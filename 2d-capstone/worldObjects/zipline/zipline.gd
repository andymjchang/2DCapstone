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
			var destination = get_parent().get_child(END)
			var newVelocity = (destination.position - self.position) / 2
			print("Destination: ", destination.position)
			print("Velocity: ", newVelocity)
			body.velocity.x = Globals.pixelsPerFrame * Globals.scrollSpeed
			body.inZipline = true
			body.relocating = true

		elif self.name == "ziplineEnd" and body.inZipline:
			print("at end")
			body.inZipline = false
			body.relocating = false
			body.position.y -= 100
			body.velocity = Vector2(0, 0)

	pass
