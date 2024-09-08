extends Camera2D

@export var bpm = 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = position.x + bpm * delta
