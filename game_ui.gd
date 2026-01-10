extends CanvasLayer

@onready var hp_label = $Label
@onready var money_label = $MoneyLabel
@onready var cargo_label = $CargoLabel
@onready var fuel_bar = $FuelBar
@onready var fuel_label = $FuelBar/FuelLabel
@onready var trade_window = $TradeWindow
@onready var trade_label = $TradeWindow/PortLabel
@onready var repair_button = $TradeWindow/RepairButton
@onready var buy_button = $TradeWindow/BuyButton
@onready var sell_button = $TradeWindow/SellButton
@onready var refuel_button = $TradeWindow/RefuelButton

var current_port: Node2D = null

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("GameUI found player: ", player)
		# Update initial value
		_on_player_hp_changed(player.hp)
		_on_player_money_changed(player.money)
		_on_player_cargo_changed(player.cargo_amount)
		_on_player_fuel_changed(player.current_fuel)
		
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

func _on_player_hp_changed(new_hp):
	print("GameUI received hp_changed: ", new_hp)
	if hp_label:
		hp_label.text = "HP: " + str(new_hp)

func _on_player_money_changed(amount):
	if money_label:
		money_label.text = "$" + str(amount)

func _on_player_cargo_changed(amount):
	if cargo_label:
		cargo_label.text = "Cargo: " + str(amount)

func _on_player_fuel_changed(amount):
	if fuel_bar:
		fuel_bar.value = amount
	if fuel_label:
		fuel_label.text = "Fuel: " + str(int(amount)) + "%"

func _on_repair_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.change_money(-50):
			player.heal_full()
			print("Repaired!")
		else:
			print("Not enough cash!")

func _on_buy_button_pressed():
	if current_port == null:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.money >= current_port.buy_price:
			player.change_money(-current_port.buy_price)
			player.change_cargo(1)
			print("Bought cargo for ", current_port.buy_price)
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
		
	# Update button text with prices
	if buy_button:
		buy_button.text = "Buy ($" + str(port_node.buy_price) + ")"
	if sell_button:
		sell_button.text = "Sell ($" + str(port_node.sell_price) + ")"

func on_port_exited():
	current_port = null
	if trade_window:
		trade_window.visible = false
