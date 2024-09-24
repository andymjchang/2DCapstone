extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fillBlockScroll()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func fillBlockScroll() -> void:
	var button = Button.new()
	#button.text = "Platform Block"
	#button.connect("pressed",self.get_parent().get_parent().get_parent()._on_block_button_button_up())
	#self.get_child(0).add_child(button)
	#button = Button.new()
	#button.text = "Goal Block"
	#button.connect("pressed",self.get_parent().get_parent().get_parent()._on_goal_button_button_up())
	#self.get_child(0).add_child(button)
	
	
	
	
	
	
