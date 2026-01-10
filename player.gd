extends CharacterBody2D

signal hp_changed(new_hp)
signal money_changed(amount)

@export var max_speed = 400
@export var friction = 0.1

var hp = 100
var money = 100
var is_dead = false

func _ready():
	add_to_group("player")

func take_damage(amount):
	if is_dead:
		return
	
	hp -= amount
	print("Player took damage: ", amount, " New HP: ", hp)
	emit_signal("hp_changed", hp)
	
	if hp <= 0:
		is_dead = true
		get_tree().call_deferred("reload_current_scene")

func change_money(amount):
	if amount < 0 and money + amount < 0:
		return false
	money += amount
	money_changed.emit(money)
	return true

func heal_full():
	hp = 100
	hp_changed.emit(hp)

func _physics_process(_delta: float) -> void:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = velocity.lerp(input_vector * max_speed, friction)
	move_and_slide()
	
	# Only rotate if we have significant velocity to avoid jitter
	if velocity.length() > 0.1:
		rotation = velocity.angle()


func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
