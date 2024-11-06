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
			var destination = get_parent().get_child(END).get_node("Marker2D")
			var start = get_parent().get_child(START).get_node("Marker2D")
			var direction = (destination.global_position - start.global_position).normalized()
			body.position.y = start.get_parent().get_node("PlayerMarker").global_position.y
			#body.position.y = start.get_parent().get_node("playerMarker").global_position.y
			print("Destination: ", destination.global_position)
			print("Velocity: ", direction)
			#body.position -= direction * Globals.pixelsPerFrame * Globals.scrollSpeed
			body.velocity = direction * Globals.pixelsPerFrame * Globals.scrollSpeed
			#body.velocity.x = Globals.pixelsPerFrame * Globals.scrollSpeed
			#body.velocity.y =
			body.inZipline = true
			body.relocating = true
			Globals.vertical = true

		elif self.name == "ziplineEnd" and body.inZipline:
			print("at end")
			body.inZipline = false
			body.relocating = false
			body.get_node("Animation").play("Run")
			body.position.y -= 100
			body.velocity = Vector2(0, 0)
			Globals.vertical = false
			Globals.resetCamera = true

	pass
