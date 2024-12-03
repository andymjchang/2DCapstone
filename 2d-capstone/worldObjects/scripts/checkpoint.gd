extends Node2D

var curSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.curFile == "Level 3":
		$Checkpoint2.visible = true
	elif Globals.curFile == "Level 4":
		$Checkpoint3.visible = true
	else:
		$Checkpoint1.visible = true

func _onBoundsAreaEntered(area):	
	# Relocating player has reached checkpoint
	if area.name == "CheckpointHitbox" && area.get_parent().relocating:
		print("Hit!")
		area.get_parent().reachedCheckpoint = true
		area.get_parent().velocity.x = 0
		area.get_parent().velocity.y = 0
		area.get_parent().position = self.position
	pass
	
