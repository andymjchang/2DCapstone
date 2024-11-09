extends Node2D


@onready var startSprite = $start/Sprite2D
@onready var endSprite = $end/Sprite2D
@onready var start = $start/Area2D
@onready var end = $end/Area2D

var coords
var connectingLine : Line2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$end.global_position.x += 50
	coords = [Vector2(INF, INF), Vector2(INF, INF)]
	startSprite.modulate = Color(0,1,0)
	endSprite.modulate = Color(1,0,0)
	
	#set up the line
	#connectingLine = Line2D.new()
	#connectingLine.width = 3
	#connectingLine.default_color = Color(0,1,0)
	#connectingLine.points = coords
	#self.add_child(connectingLine)
	#
	#_draw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
		
func _draw():
	if start.global_position != coords[0] or end.global_position != coords[1]:
		#we need to update the line
		print("drawing line: ",$start.global_position," ", $end.global_position)
		coords = [$start.global_position, $end.global_position]
		draw_line(coords[0], coords[1], Color.WEB_PURPLE,0.2)
		
func save() -> String:
	#posChain = str(blockChild.global_position.x) + ", " + str(blockChild.global_position.y)+", "+ str(blockChild.get_parent().enemyType)+", "
	return str($start.global_position.x) + ", " + str($start.global_position.y) +", "+ str($end.global_position.x) + ", " + str($end.global_position.y) + ", "

func load(posPoints) -> void:
	if posPoints.size() >= 4:
		$start.global_position = Vector2(posPoints[0], posPoints[1])
		$end.global_position = Vector2(posPoints[2], posPoints[3])
	
