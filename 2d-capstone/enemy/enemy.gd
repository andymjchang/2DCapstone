extends Node2D
signal playerspotted
signal takeDamage

var count = 0

var soundPlayer := AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	add_child(soundPlayer)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("players") and body.attack.visible:
		self.visible = false
	elif body.is_in_group("players"):
		#here if we want it lol, doesnt work as of now
		#var soundEffect = load("res://audioTracks/record-scratches-31350.mp3")
		#soundPlayer.stream = soundEffect
		#soundPlayer.play()
		body.emit_signal("takeDamage",1)
	pass # Replace with function body.
	
