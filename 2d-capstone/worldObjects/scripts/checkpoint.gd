extends Node2D

var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	#curSprite = get_node("Sprite2D").duplicate()
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
		area.get_parent().position = self.position
	pass
	
