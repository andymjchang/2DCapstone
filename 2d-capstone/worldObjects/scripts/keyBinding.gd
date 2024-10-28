extends Node2D

var pathToImage = ""
var imageName = ""
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setImage(posPoints : Array) -> void:
	if posPoints.size() > 2.0:
		var path = posPoints[2]
		pathToImage = path
		#var endFile = path.get_file()
		#imageName = endFile.get_basename()
		#sprite.texture = load(path)
		
