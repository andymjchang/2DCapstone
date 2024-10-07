extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.inLevel:
		pass
		#position.x = position.x + Globals.pixelsPerFrame * delta
