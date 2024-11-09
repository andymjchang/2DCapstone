extends Node2D

@onready var startSprite = $start/Sprite2D
@onready var endSprite = $end/Sprite2D
@onready var start = $start/Area2D
@onready var end = $end/Area2D

var coords
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$end.global_position.x += 50
	coords = [Vector2(INF, INF), Vector2(INF, INF)]
	endSprite.modulate = Color(1,0,0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
