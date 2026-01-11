extends Node2D

var cloud_scene = preload("res://cloud.tscn")

func _ready():
	generate_fog()

func generate_fog():
	# Generate clouds in a grid
	var start_x = -3000
	var end_x = 3000
	var start_y = -3000
	var end_y = 3000
	var step = 300 # Distance between clouds
	
	for x in range(start_x, end_x, step):
		for y in range(start_y, end_y, step):
			var cloud = cloud_scene.instantiate()
			cloud.position = Vector2(x, y)
			add_child(cloud)
			
	print("Fog generated with grid range: ", start_x, " to ", end_x)

func reveal_area(center_pos: Vector2, radius: float):
	# Optional manual reveal logic (expensive to iterate all, better to use collisions)
	for child in get_children():
		if child.has_method("reveal") and child.global_position.distance_to(center_pos) < radius:
			child.reveal()
