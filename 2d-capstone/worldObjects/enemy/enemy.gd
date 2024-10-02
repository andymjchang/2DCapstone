extends Node2D
signal playerspotted
signal takeDamage

var count = 0
var ifDead = false
var secondTime = false
var blockType = "enemy"

var up
var down 
var left
var right
var index = 0

var curSprite

var soundPlayer := AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	add_child(soundPlayer)
	up = "up"
	down = "down"
	left = "left"
	right = "right"
	curSprite = get_node("Sprite2D").duplicate()
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ifDead:
		$Sprite2D.position.y += 4
		$Sprite2D.rotation = 0.8
		
	
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("players") and body.attack.visible:
		self.ifDead = true
		print("enemy punched")
		get_parent().get_parent().get_parent().get_node("ScoreBar/TextureProgressBar").emit_signal("increaseScore")
		print("bar, ", get_parent().get_parent().get_parent().get_node("ScoreBar"))
	elif body.is_in_group("players"):
		#here if we want it lol, doesnt work as of now
		#var soundEffect = load("res://audioTracks/record-scratches-31350.mp3")
		#soundPlayer.stream = soundEffect
		#soundPlayer.play()
		body.emit_signal("takeDamage",1)
	pass # Replace with function body.

func snapToNextBeat():
	var stepSize = Globals.stepSize
	print("step size: ", stepSize)
	self.position.x += stepSize
	

		
	
	
