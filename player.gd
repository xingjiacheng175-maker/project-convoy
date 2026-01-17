extends CharacterBody2D

signal hp_changed(new_hp)
signal money_changed(amount)
signal cargo_changed(new_amount)
signal inventory_updated(inventory_data)
signal fuel_changed(new_fuel)

@export var base_speed = 400.0
@export var friction = 0.1
@export var weight_penalty = 30.0
@export var min_speed = 50.0

@onready var compass_pivot = $CompassPivot
@onready var distance_label = $CompassPivot/ArrowShape/DistanceLabel
var navigation_target: Node2D = null

var hp = 100
var money = 100
var inventory = {}
var is_dead = false
var current_mission = {}
var has_mission = false

var max_cargo = 5
var engine_level = 1
var cargo_level = 1
var fuel_level = 1

# Fuel System
var max_fuel = 100.0
var current_fuel = 100.0
var fuel_consumption_rate = 2.0 # Fuel/sec

func _ready():
	add_to_group("player")
	
	# Task 3: Camera Unlock/Expansion
	var camera = $Camera2D
	if camera:
		# Unlock camera limits to allow exploration
		camera.limit_left = -100000
		camera.limit_top = -100000
		camera.limit_right = 100000
		camera.limit_bottom = 100000

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

func get_total_cargo_count() -> int:
	var total = 0
	for count in inventory.values():
		total += count
	return total

func add_item(item_name: String, amount: int) -> bool:
	if get_total_cargo_count() + amount > max_cargo:
		return false
	
	if not inventory.has(item_name):
		inventory[item_name] = 0
	inventory[item_name] += amount
	
	cargo_changed.emit(get_total_cargo_count())
	inventory_updated.emit(inventory)
	print("UI Update Signal Sent via add_item") # Debug
	return true

func remove_item(item_name: String, amount: int) -> bool:
	if not inventory.has(item_name) or inventory[item_name] < amount:
		return false
	
	inventory[item_name] -= amount
	if inventory[item_name] <= 0:
		inventory.erase(item_name)
	
	cargo_changed.emit(get_total_cargo_count())
	inventory_updated.emit(inventory)
	print("UI Update Signal Sent via remove_item") # Debug
	return true

func upgrade_engine():
	if money >= 200:
		change_money(-200)
		base_speed += 50
		engine_level += 1
		print("Engine Upgraded to Level ", engine_level)
		return true
	return false

func upgrade_cargo():
	if money >= 300:
		change_money(-300)
		max_cargo += 3
		cargo_level += 1
		print("Cargo Expanded to Level ", cargo_level, " (Max: ", max_cargo, ")")
		return true
	return false

func upgrade_fuel():
	if money >= 150:
		change_money(-150)
		max_fuel += 50
		current_fuel = max_fuel # Refill on upgrade
		fuel_level += 1
		fuel_changed.emit(current_fuel)
		print("Fuel Tank Upgraded to Level ", fuel_level, " (Max: ", max_fuel, ")")
		return true
	return false

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
	var effective_cargo = get_total_cargo_count()
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
	var effective_cargo = get_total_cargo_count()
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
		
	# Update Compass Logic
	if navigation_target != null:
		# 1. Point the arrow
		compass_pivot.look_at(navigation_target.global_position)
		# Correct for parent rotation if compass is child of rotating player?
		# Actually look_at sets global rotation. Since CompassPivot is child of Player
		# and Player rotates, we might need to adjust or make CompassPivot not inherit rotation.
		# However, Node2D.look_at sets global_rotation so it points to target regardless of parent.
		# But wait, look_at modifies the node's rotation property relative to parent to achieve the global look direction.
		# So calling look_at every frame is correct.
		
		# 2. Calculate and Show Distance
		var dist = global_position.distance_to(navigation_target.global_position)
		# Convert pixels to "km" (assuming 100px = 1km for flavor)
		var km = int(dist / 100)
		distance_label.text = str(km) + " km"
		# Keep label upright? (Optional polish)
		# Control nodes don't have global_rotation, so we calculate local rotation
		distance_label.rotation = -distance_label.get_parent().global_rotation 


func set_navigation_target(target_port_node):
	navigation_target = target_port_node
	compass_pivot.visible = true
	print("Navigation set to: ", target_port_node.name)

func clear_navigation():
	navigation_target = null
	compass_pivot.visible = false

func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
