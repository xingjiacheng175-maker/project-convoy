extends CharacterBody2D

@export var speed = 100
var hp = 3

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		look_at(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Check for collision with player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("player"):
				if collider.has_method("take_damage"):
					collider.take_damage(1)
