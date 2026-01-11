extends CanvasLayer

@onready var hp_label = $Label
@onready var money_label = $MoneyLabel
@onready var cargo_label = $CargoLabel
@onready var fuel_bar = $FuelBar
@onready var fuel_label = $FuelBar/FuelLabel
@onready var range_label = $RangeLabel
@onready var scanner_panel = $ScannerPanel
@onready var trade_window = $TradeWindow
@onready var trade_label = $TradeWindow/PortLabel
@onready var mission_label = $TradeWindow/MissionLabel
@onready var mission_button = $TradeWindow/MissionButton
@onready var shipyard_button = $TradeWindow/ShipyardButton
@onready var shipyard_panel = $TradeWindow/ShipyardPanel
@onready var upgrade_engine_btn = $TradeWindow/ShipyardPanel/UpgradeEngine
@onready var upgrade_cargo_btn = $TradeWindow/ShipyardPanel/UpgradeCargo
@onready var upgrade_fuel_btn = $TradeWindow/ShipyardPanel/UpgradeFuel
@onready var close_shipyard_btn = $TradeWindow/ShipyardPanel/CloseShipyard
@onready var repair_button = $TradeWindow/RepairButton
@onready var buy_button = $TradeWindow/BuyButton
@onready var sell_button = $TradeWindow/SellButton
@onready var refuel_button = $TradeWindow/RefuelButton

var current_port: Node2D = null
var scanner_labels = {}

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("GameUI found player: ", player)
		# Update initial value
		_on_player_hp_changed(player.hp)
		_on_player_money_changed(player.money)
		_on_player_cargo_changed(player.cargo_amount)
		_on_player_fuel_changed(player.current_fuel)
		update_range_display()
		
		# Connect signals
		if not player.hp_changed.is_connected(_on_player_hp_changed):
			player.hp_changed.connect(_on_player_hp_changed)
			print("Connected hp_changed signal")
		if not player.money_changed.is_connected(_on_player_money_changed):
			player.money_changed.connect(_on_player_money_changed)
		if not player.cargo_changed.is_connected(_on_player_cargo_changed):
			player.cargo_changed.connect(_on_player_cargo_changed)
		if not player.fuel_changed.is_connected(_on_player_fuel_changed):
			player.fuel_changed.connect(_on_player_fuel_changed)
	else:
		print("GameUI: Player not found in group 'player'")
	
	# Initialize Scanner Labels
	var ports = get_tree().get_nodes_in_group("ports")
	for port in ports:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 20)
		scanner_panel.add_child(label)
		scanner_labels[port] = label
		
	if mission_button:
		if not mission_button.pressed.is_connected(_on_mission_button_pressed):
			mission_button.pressed.connect(_on_mission_button_pressed)
			
	# Connect Shipyard Signals
	if shipyard_button and not shipyard_button.pressed.is_connected(_on_shipyard_button_pressed):
		shipyard_button.pressed.connect(_on_shipyard_button_pressed)
	if close_shipyard_btn and not close_shipyard_btn.pressed.is_connected(_on_close_shipyard_pressed):
		close_shipyard_btn.pressed.connect(_on_close_shipyard_pressed)
	if upgrade_engine_btn and not upgrade_engine_btn.pressed.is_connected(_on_upgrade_engine_pressed):
		upgrade_engine_btn.pressed.connect(_on_upgrade_engine_pressed)
	if upgrade_cargo_btn and not upgrade_cargo_btn.pressed.is_connected(_on_upgrade_cargo_pressed):
		upgrade_cargo_btn.pressed.connect(_on_upgrade_cargo_pressed)
	if upgrade_fuel_btn and not upgrade_fuel_btn.pressed.is_connected(_on_upgrade_fuel_pressed):
		upgrade_fuel_btn.pressed.connect(_on_upgrade_fuel_pressed)
			
	if repair_button:
		if not repair_button.pressed.is_connected(_on_repair_button_pressed):
			repair_button.pressed.connect(_on_repair_button_pressed)
			
	if buy_button:
		if not buy_button.pressed.is_connected(_on_buy_button_pressed):
			buy_button.pressed.connect(_on_buy_button_pressed)
			
	if sell_button:
		if not sell_button.pressed.is_connected(_on_sell_button_pressed):
			sell_button.pressed.connect(_on_sell_button_pressed)
			
	if refuel_button:
		if not refuel_button.pressed.is_connected(_on_refuel_button_pressed):
			refuel_button.pressed.connect(_on_refuel_button_pressed)

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for port in scanner_labels.keys():
			var label = scanner_labels[port]
			var dist = player.global_position.distance_to(port.global_position)
			
			if port.is_discovered:
				label.text = port.port_name + ": " + str(int(dist)) + "m"
				label.modulate = Color(0.2, 1, 0.2) # Green
			else:
				label.text = "Unknown Signal: " + str(int(dist)) + "m"
				label.modulate = Color(0.5, 0.5, 0.5) # Gray

func _on_player_hp_changed(new_hp):
	print("GameUI received hp_changed: ", new_hp)
	if hp_label:
		hp_label.text = "HP: " + str(new_hp)

func _on_player_money_changed(amount):
	if money_label:
		money_label.text = "$" + str(amount)

func _on_player_cargo_changed(amount):
	if cargo_label:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			cargo_label.text = "Cargo: " + str(amount) + "/" + str(player.max_cargo)
		else:
			cargo_label.text = "Cargo: " + str(amount)
	update_range_display()

func _on_player_fuel_changed(amount):
	if fuel_bar:
		fuel_bar.value = amount
	if fuel_label:
		fuel_label.text = "Fuel: " + str(int(amount)) + "%"
	update_range_display()

func _on_mission_button_pressed():
	if current_port == null:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and current_port.available_mission.size() > 0:
		player.current_mission = current_port.available_mission
		player.has_mission = true
		mission_button.disabled = true
		mission_button.text = "Accepted"
		mission_label.text = "Mission: Deliver to " + player.current_mission.target_name
		print("Mission Accepted: ", player.current_mission)

func _on_shipyard_button_pressed():
	if shipyard_panel:
		shipyard_panel.visible = true
		# Hide trade elements
		if buy_button: buy_button.visible = false
		if sell_button: sell_button.visible = false
		if mission_label: mission_label.visible = false
		if mission_button: mission_button.visible = false
		if repair_button: repair_button.visible = false
		if refuel_button: refuel_button.visible = false
		update_shipyard_ui()

func _on_close_shipyard_pressed():
	if shipyard_panel:
		shipyard_panel.visible = false
		# Show trade elements
		if buy_button: buy_button.visible = true
		if sell_button: sell_button.visible = true
		if mission_label: mission_label.visible = true
		if mission_button: mission_button.visible = true
		if repair_button: repair_button.visible = true
		if refuel_button: refuel_button.visible = true

func update_shipyard_ui():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Update Engine Button
		var engine_cost = 200
		if player.money >= engine_cost:
			upgrade_engine_btn.disabled = false
			upgrade_engine_btn.text = "Upgrade Engine ($" + str(engine_cost) + ") - Lvl " + str(player.engine_level) + " -> " + str(player.engine_level + 1)
		else:
			upgrade_engine_btn.disabled = true
			upgrade_engine_btn.text = "Upgrade Engine ($" + str(engine_cost) + ") - Not Enough Cash"
			
		# Update Cargo Button
		var cargo_cost = 300
		if player.money >= cargo_cost:
			upgrade_cargo_btn.disabled = false
			upgrade_cargo_btn.text = "Expand Cargo ($" + str(cargo_cost) + ") - Lvl " + str(player.cargo_level) + " -> " + str(player.cargo_level + 1)
		else:
			upgrade_cargo_btn.disabled = true
			upgrade_cargo_btn.text = "Expand Cargo ($" + str(cargo_cost) + ") - Not Enough Cash"
			
		# Update Fuel Button
		var fuel_cost = 150
		if player.money >= fuel_cost:
			upgrade_fuel_btn.disabled = false
			upgrade_fuel_btn.text = "Bigger Tank ($" + str(fuel_cost) + ") - Lvl " + str(player.fuel_level) + " -> " + str(player.fuel_level + 1)
		else:
			upgrade_fuel_btn.disabled = true
			upgrade_fuel_btn.text = "Bigger Tank ($" + str(fuel_cost) + ") - Not Enough Cash"

func _on_upgrade_engine_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.upgrade_engine():
		update_shipyard_ui()

func _on_upgrade_cargo_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.upgrade_cargo():
		update_shipyard_ui()
		# Update cargo UI since max changed (optional, if we show max)
		_on_player_cargo_changed(player.cargo_amount)

func _on_upgrade_fuel_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.upgrade_fuel():
		update_shipyard_ui()

func _on_repair_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.change_money(-50):
			player.heal_full()
			print("Repaired!")
		else:
			print("Not enough cash!")

func update_range_display():
	if range_label:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var range_val = player.get_estimated_range()
			range_label.text = "Range: " + str(int(range_val)) + " km"

func _on_buy_button_pressed():
	if current_port == null:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.money >= current_port.buy_price:
			if player.change_cargo(1):
				player.change_money(-current_port.buy_price)
				print("Bought cargo for ", current_port.buy_price)
			else:
				print("Cargo full!")
		else:
			print("Not enough cash to buy cargo!")

func _on_sell_button_pressed():
	if current_port == null:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.cargo_amount > 0:
			player.change_cargo(-1)
			player.change_money(current_port.sell_price)
			print("Sold cargo for ", current_port.sell_price)
		else:
			print("No cargo to sell!")

func _on_refuel_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.refuel(100, 20): # Fill up 100 units for $20
			print("Refueled!")
		else:
			print("Not enough cash to refuel!")

func on_port_entered(port_node):
	current_port = port_node
	if trade_window:
		trade_window.visible = true
	if trade_label:
		trade_label.text = "Welcome to " + port_node.port_name
		
	# Mission Logic
	var player = get_tree().get_first_node_in_group("player")
	
	# Check for Mission Completion
	if player and player.has_mission:
		if player.current_mission.target_name == port_node.port_name:
			# Complete Mission
			player.change_money(player.current_mission.reward)
			print("Mission Completed! Reward: ", player.current_mission.reward)
			player.has_mission = false
			player.current_mission = {}
			if mission_label:
				mission_label.text = "Mission Complete! +$" + str(port_node.available_mission.get("reward", 0)) # Note: Logic slightly off, using available for display, but logic is fine
				mission_label.text = "Mission Complete!"
	
	# Update Mission UI for new missions
	if mission_label:
		if player.has_mission:
			mission_label.text = "Current: Deliver to " + player.current_mission.target_name
			if mission_button:
				mission_button.disabled = true
				mission_button.text = "Has Mission"
		elif port_node.available_mission.size() > 0:
			mission_label.text = "Contract: Deliver to " + port_node.available_mission.target_name + " ($" + str(port_node.available_mission.reward) + ")"
			if mission_button:
				mission_button.disabled = false
				mission_button.text = "Accept Mission"
		else:
			mission_label.text = "No missions available"
			if mission_button:
				mission_button.disabled = true
		
	# Update button text with prices
	if buy_button:
		buy_button.text = "Buy ($" + str(port_node.buy_price) + ")"
	if sell_button:
		sell_button.text = "Sell ($" + str(port_node.sell_price) + ")"

func on_port_exited():
	current_port = null
	if trade_window:
		trade_window.visible = false


func _on_accept_mission_button_pressed() -> void:
	pass # Replace with function body.
