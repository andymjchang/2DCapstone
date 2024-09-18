extends Node2D

var index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _onBoundsAreaEntered(area):
	# Relocating player has reached checkpoint
	if area.name == "CheckpointHitbox" && area.get_parent().relocating:
		print("Hit!")
		area.get_parent().reachedCheckpoint = true
		area.get_parent().velocity.x = 0
		area.get_parent().velocity.y = 0
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("click")
		get_parent().get_parent().get_parent().emit_signal("objectClicked",index)
	pass # Replace with function body.
