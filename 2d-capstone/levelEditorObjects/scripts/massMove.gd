extends Node2D

@onready var sprite = $Node2D/Sprite2D
@onready var node = $Node2D
var axisTypes = ["vertical", "horizontal"]
var axisType = "vertical"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#we want to allow the user to change the axis
	if Input.is_action_just_pressed("rotate") and get_tree().current_scene.currentBlock and self.get_parent().index == get_tree().current_scene.currentBlock.index:
		lineRotate()
	

func lineRotate() -> void:
	if axisType == axisTypes[0]:
		#changing from vertical to horizontal
		axisType = axisTypes[1]
		node.rotation_degrees = 90
	else:
		#changing from horizontal to verticl
		axisType = axisTypes[0]
		node.rotation_degrees = 0
	get_tree().current_scene.emit_signal("setMassMove",node.global_position, true)
		
