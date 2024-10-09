extends Node2D



func _ready():
	$AnimatedSprite2D.frame = randi() % 7
