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
var current_mission = {}
var has_mission = false

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

func get_current_max_speed():
	# If has mission, add extra weight (simulate 3 cargo units)
	var effective_cargo = cargo_amount
	if has_mission:
		effective_cargo += 3
		
	var speed = max(base_speed - (effective_cargo * weight_penalty), min_speed)
	if current_fuel <= 0:
		speed *= 0.1
	return speed

func get_estimated_range():
	if fuel_consumption_rate <= 0:
		return 0.0
	return (current_fuel / fuel_consumption_rate) * get_current_max_speed()

func _physics_process(delta: float) -> void:
	# Calculate dynamic max speed based on cargo
	var current_max_speed = get_current_max_speed()
	
	# Calculate dynamic friction based on cargo (heavier = more sluggish)
	# Base friction is 0.1. We reduce it slightly per cargo unit.
	var effective_cargo = cargo_amount
	if has_mission:
		effective_cargo += 3
	var current_friction = max(friction - (effective_cargo * 0.005), 0.02)
	
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
