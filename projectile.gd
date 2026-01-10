extends Area2D

var speed = 600

func _ready() -> void:
	# Connect signals if nodes exist, assuming standard naming
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	var notifier = get_node_or_null("VisibleOnScreenNotifier2D")
	if notifier and not notifier.screen_exited.is_connected(_on_screen_exited):
		notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()

func _on_screen_exited() -> void:
	queue_free()
