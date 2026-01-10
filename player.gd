extends CharacterBody2D

signal hp_changed(new_hp)
signal money_changed(amount)
signal cargo_changed(new_amount)
signal fuel_changed(new_fuel)

@export var base_speed = 400.0
@export var friction = 0.1
@export var weight_penalty = 30.0
@export var min_speed = 50.0

var hp = 100
var money = 100
var cargo_amount = 0
var is_dead = false

# Fuel System
var max_fuel = 100.0
var current_fuel = 100.0
var fuel_consumption_rate = 2.0 # Fuel/sec

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

func change_cargo(amount):
	if amount < 0 and cargo_amount + amount < 0:
		return false
	cargo_amount += amount
	cargo_changed.emit(cargo_amount)
	return true

func heal_full():
	hp = 100
	hp_changed.emit(hp)

func refuel(amount, cost):
	if money >= cost:
		change_money(-cost)
		current_fuel = min(current_fuel + amount, max_fuel)
		fuel_changed.emit(current_fuel)
		return true
	return false

func _physics_process(delta: float) -> void:
	# Calculate dynamic max speed based on cargo
	var current_max_speed = max(base_speed - (cargo_amount * weight_penalty), min_speed)
	
	# Calculate dynamic friction based on cargo (heavier = more sluggish)
	# Base friction is 0.1. We reduce it slightly per cargo unit.
	var current_friction = max(friction - (cargo_amount * 0.005), 0.02)
	
	# Fuel penalty
	if current_fuel <= 0:
		current_max_speed *= 0.1 # 90% speed penalty if out of fuel
	
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Fuel consumption
	if input_vector.length() > 0 and current_fuel > 0:
		current_fuel -= fuel_consumption_rate * delta
		if current_fuel < 0:
			current_fuel = 0
		fuel_changed.emit(current_fuel)
	
	velocity = velocity.lerp(input_vector * current_max_speed, current_friction)
	move_and_slide()
	
	# Only rotate if we have significant velocity to avoid jitter
	if velocity.length() > 0.1:
		rotation = velocity.angle()


func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
