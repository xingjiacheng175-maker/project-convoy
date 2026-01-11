@tool
extends StaticBody2D

@export var map_radius: float = 5000.0

func _ready():
	z_index = 100 # Ensure it's drawn on top
	queue_redraw()
	
	if not Engine.is_editor_hint():
		create_walls()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	# Draw a hollow rectangle to visualize the map limits
	# Rect2(x, y, width, height)
	var rect = Rect2(-map_radius, -map_radius, map_radius * 2, map_radius * 2)
	var color = Color.RED
	var line_width = 50.0
	
	draw_rect(rect, color, false, line_width)

func create_walls():
	# Top Wall
	add_wall(Vector2(0, -map_radius), Vector2(0, 1))
	# Bottom Wall
	add_wall(Vector2(0, map_radius), Vector2(0, -1))
	# Left Wall
	add_wall(Vector2(-map_radius, 0), Vector2(1, 0))
	# Right Wall
	add_wall(Vector2(map_radius, 0), Vector2(-1, 0))

func add_wall(pos: Vector2, normal: Vector2):
	var collision = CollisionShape2D.new()
	var shape = WorldBoundaryShape2D.new()
	shape.normal = normal
	collision.shape = shape
	collision.position = pos
	add_child(collision)

