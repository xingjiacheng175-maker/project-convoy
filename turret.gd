extends Node2D

@export var projectile_scene: PackedScene
var target: Node2D = null
var targets: Array[Node2D] = []

func _ready() -> void:
	var range_area = get_node_or_null("Range")
	if range_area:
		if not range_area.body_entered.is_connected(_on_range_body_entered):
			range_area.body_entered.connect(_on_range_body_entered)
		if not range_area.body_exited.is_connected(_on_range_body_exited):
			range_area.body_exited.connect(_on_range_body_exited)
	
	var timer = get_node_or_null("Timer")
	if timer and not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func _physics_process(_delta: float) -> void:
	# Filter out invalid targets (freed instances)
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	if targets.size() > 0:
		target = targets[0]
		look_at(target.global_position)
	else:
		target = null

func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		targets.append(body)

func _on_range_body_exited(body: Node2D) -> void:
	if body in targets:
		targets.erase(body)

func _on_timer_timeout() -> void:
	if target and is_instance_valid(target) and projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.rotation = rotation
		get_tree().root.add_child(projectile)
