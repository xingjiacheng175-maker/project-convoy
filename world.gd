extends Node2D

func _ready():
	# Instantiate Fog Manager
	var fog_manager_script = load("res://fog_manager.gd")
	var fog_manager = Node2D.new()
	fog_manager.set_script(fog_manager_script)
	fog_manager.name = "FogManager"
	add_child(fog_manager)
	
	# Since we are adding it via code, we need to manually trigger _ready if it wasn't in tree yet
	# But add_child calls _ready automatically when entering tree.
