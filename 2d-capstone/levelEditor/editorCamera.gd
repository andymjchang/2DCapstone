extends Camera2D

var is_panning = false
var last_mouse_position = Vector2.ZERO
var redraw = false

@onready var measureLines = get_parent().get_node("measureLines")

# Zoom variables
var zoom_speed = 0.1
var min_zoom = 0.5
var max_zoom = 2.0
var target_zoom = Vector2.ONE

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# Middle mouse button pressed
				is_panning = true
				last_mouse_position = event.position
			else:
				# Middle mouse button released
				is_panning = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom in
			target_zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom out
			target_zoom += Vector2(zoom_speed, zoom_speed)
		
		# Clamp the zoom level
		target_zoom = target_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	
	elif event is InputEventMouseMotion and is_panning:
		# Calculate the difference in mouse position
		var delta = event.position - last_mouse_position
		
		# Move the camera in the opposite direction of the mouse movement
		position -= delta
		
		# Update the last mouse position
		last_mouse_position = event.position

func _process(_delta):
	# Smoothly interpolate current zoom to target zoom
	zoom = zoom.lerp(target_zoom, 0.1)
	
	if Input.is_action_just_pressed("moveCameraLeft"):
		position.x -= 200
	if Input.is_action_just_pressed("moveCameraRight"):	
		position.x += 200
