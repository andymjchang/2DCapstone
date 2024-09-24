extends Node2D
#signal decreaseHealth()

var healthStatus= "full"
@onready var fullHealth = $fullHealth
@onready var halfHealth = $halfHealth


# Called when the node enters the scene tree for the first time.
#TODO add this for both players
func _ready() -> void:
	#connect signal for when player takes damage
	#self.decreaseHealth.connect(_onDamageTaken)
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
#is this redundant?	
func takeDamage() -> void:
	match healthStatus:
		"full":
			#decrease to half
			self.fullHealth.visible = false
			self.halfHealth.visible = true
			healthStatus = "half"
		"half":
			#no more heart :(
			self.halfHealth.visible = false
			healthStatus = "zero"
		"zero":
			#should not be getting here
			print("should not be checking heart still")
	
	
