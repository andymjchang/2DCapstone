extends Node2D

@onready var startSprite = $start/Sprite2D
@onready var start = $start

@onready var endSprite = $end/Sprite2D
@onready var end = $end
var axisTypes = ["vertical", "horizontal"]
var axisType = "vertical"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startSprite.modulate = Color(0, 1, 0)
	endSprite.modulate = Color(1, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#we want to allow the user to change the axis
	if Input.is_action_just_pressed("rotate") and get_tree().current_scene.currentBlock and self.get_parent().index == get_tree().current_scene.currentBlock.index:
		lineRotate()
		
	#we align the end to the start always
	
	#if th elines are vertical, then both lines should have the same 
	if axisType == axisTypes[0]:
		end.global_position.y = start.global_position.y
		$end.global_position.y = $start.global_position.y
		$end/EditorArea1/CollisionShape2D.shape.extents = $start/EditorArea0/CollisionShape2D.shape.extents 
	else:
		end.global_position.x = start.global_position.x
		$end.global_position.x = $start.global_position.x
		$end/EditorArea1/CollisionShape2D.shape.extents = $start/EditorArea0/CollisionShape2D.shape.extents 
		
		
func snapEnd() -> void:
	if axisType == axisTypes[0]:
		end.global_position.y = start.global_position.y
		$end.global_position.y = $start.global_position.y
		$end/EditorArea1/CollisionShape2D.shape.extents = $start/EditorArea0/CollisionShape2D.shape.extents 
	else:
		end.global_position.x = start.global_position.x
		$end.global_position.x = $start.global_position.x
		$end/EditorArea1/CollisionShape2D.shape.extents = $start/EditorArea0/CollisionShape2D.shape.extents 


func lineRotate() -> void:
	if axisType == axisTypes[0]:
		#changing from vertical to horizontal
		axisType = axisTypes[1]
		start.rotation_degrees = 90
		end.rotation_degrees = 90
	else:
		#changing from horizontal to verticl
		axisType = axisTypes[0]
		start.rotation_degrees = 0
		end.rotation_degrees = 0
	get_tree().current_scene.emit_signal("setMassMove", getStartEndPos(), true)
	
	
func getStartEndPos() -> Array:
	var returnVec = [start.global_position, end.global_position]
	return returnVec
	
	
func getMaxMin() -> Array:
	#get the max/min of booth coords of the start
	var startExtents = $start/EditorArea0/CollisionShape2D.shape as RectangleShape2D
		
	var startMinVec = $start.global_position - startExtents.extents
	var startMaxvec = $start.global_position + startExtents.extents
	var startMinMax = [startMinVec, startMaxvec]
	
	var endExtents = $end/EditorArea1/CollisionShape2D.shape as RectangleShape2D
	var endMinVec = $end.global_position - endExtents.extents
	var endMaxvec = $end.global_position + endExtents.extents
	#vertical ones should have the same x min and mx
	if axisType == axisTypes[0]:
		print("end min vec: ", endMinVec, "start min vec: ", startMinVec)
		print("end max vec: ", endMaxvec, "start max vec: ", startMaxvec)
		return [start.global_position.x, end.global_position.x, endMinVec.y, endMaxvec.y]
	else:
		# we are horizontal so we should have the same max/min y
		endMaxvec.x = $end.global_position.x + endExtents.extents.y
		endMinVec.x = $end.global_position.x - endExtents.extents.y
		print("end min vec: ", endMinVec, "start min vec: ", startMinVec)
		print("end max vec: ", endMaxvec, "start max vec: ", startMaxvec)
		return [end.global_position.y, start.global_position.y, endMinVec.x, endMaxvec.x]
	#horizontal ones should have the same x min and max
		
