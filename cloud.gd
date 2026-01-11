extends Area2D

func _ready():
	# Ensure we can detect the player
	# Assuming Player is on a layer that this Area2D monitors
	# Or simply rely on body_entered if masks are set up correctly
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		reveal()

func reveal():
	# Disable collision so it doesn't trigger again
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
