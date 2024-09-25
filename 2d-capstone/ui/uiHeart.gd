extends Node2D
#signal decreaseHealth()

var healthStatus= "full"
var player : String 
@onready var fullHealth = $fullP1Health
@onready var halfHealth = $halfP1Health
var changed = true


# Called when the node enters the scene tree for the first time.
#TODO add this for both players
func _ready() -> void:
	#connect signal for when player takes damage
	#self.decreaseHealth.connect(_onDamageTaken)
	if player == "player1":
		self.get_node("fullP1Health").visible = true
		self.get_node("halfP1Health").visible = false
		fullHealth = $fullP1Health
	if player == "player2":
		self.get_node("fullP2Health").visible = true
		self.get_node("halfP2Health").visible = false
		halfHealth = $halfP2Health
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == "player2" and changed:
		self.get_node("fullP2Health").visible = true
		self.get_node("halfP2Health").visible = false
		self.get_node("fullP1Health").visible = false
		self.get_node("halfP1Health").visible = false
		changed = false
		halfHealth = $halfP2Health
		fullHealth = $fullP2Health
		
#is this redundant?	
func takeDamage() -> void:
	match healthStatus:
		"full":
			#decrease to half
			self.fullHealth.visible = false
			healthStatus = "zero"
		"zero":
			#should not be getting here
			print("should not be checking heart still")
