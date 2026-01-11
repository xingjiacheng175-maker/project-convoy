@tool
extends Node2D

func _ready():
	z_index = 100 # Ensure it's drawn on top
	queue_redraw()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	# Draw a hollow rectangle to visualize the map limits
	# Rect2(x, y, width, height)
	# Starting at (-5000, -5000) with size (10000, 10000)
	var rect = Rect2(-5000, -5000, 10000, 10000)
	var color = Color.RED
	var line_width = 50.0
	
	draw_rect(rect, color, false, line_width)
