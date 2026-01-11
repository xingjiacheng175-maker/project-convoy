@tool
extends CharacterBody2D

@export var speed = 100
@export var aggro_range: float = 800.0 :
	set(value):
		aggro_range = value
		queue_redraw()

var hp = 3
var target: Node2D = null

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	# Only draw in editor or if debug mode is wanted
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, aggro_range, Color(1, 0, 0, 0.2)) # Red semi-transparent circle
		draw_arc(Vector2.ZERO, aggro_range, 0, TAU, 32, Color.RED, 2.0) # Red outline

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()

func _physics_process(_delta):
	if Engine.is_editor_hint():
		return

	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		
		if dist <= aggro_range:
			# Player is inside the circle -> CHASE
			look_at(player.global_position)
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
		else:
			# Player is outside -> IDLE / PATROL
			velocity = Vector2.ZERO
			# Optional: Rotate slowly when idle
			rotation += 1.0 * _delta
			
		move_and_slide()
		
		# Check for collision with player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				if collider.has_method("take_damage"):
					collider.take_damage(1)
