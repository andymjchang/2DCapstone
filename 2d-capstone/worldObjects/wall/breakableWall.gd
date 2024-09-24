extends Node2D

var particleEffect 
var velocities = [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]
var wallBroken = false
const FRICTION: float = 0.98
const explosionForce = 600.0
const GRAVITY = 575
var wall1
var wall2
var wall3
var wall4
var wall5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wall1 = get_node("Area2D/wallPart1")
	wall2 = get_node("Area2D/wallPart2")
	wall3 = get_node("Area2D/wallPart3")
	wall4 = get_node("Area2D/wallPart4")
	wall5 = get_node("Area2D/wallPart5")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wallBroken:
		#velocity.y += GRAVITY * delta 
		changeVelocityY(GRAVITY * delta)
		wall1.position += velocities[0] * delta
		wall2.position += velocities[1] * delta
		wall3.position += velocities[2] * delta
		wall4.position += velocities[3] * delta
		wall5.position +=velocities[4]* delta
		addFriction()
		#TODO get rid of the wall at some point after the explosion
	pass
	
	
func _on_Timer_timeout():
	queue_free()
	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	var all_players = get_tree().get_nodes_in_group("players")
	var bothPunching = true
	
	for player in all_players:
		if !player.attack.visible:
			bothPunching = false
			
	if bothPunching:
		#particleEffect.emitting = true
		particleEffect = get_node("CPUParticles2D2")
		var wallSprite = get_node("Area2D/Sprite2D")
		wallSprite.visible = false
		particleEffect.emitting = true
		particleEffect.visible = true
		getRandomVelocity()
		wallBroken = true
		#queue_free()
		#self.visible = false
	pass # Replace with function body.
	
func getRandomVelocity():
	for i in range(velocities.size()):
		velocities[i] = Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).normalized() * explosionForce
		
func changeVelocityY(delta: float):
	for i in range(velocities.size()):
		velocities[i].y += delta
		
func addFriction():
	for i in range(velocities.size()):
		velocities[i] = velocities[i]*FRICTION


	
