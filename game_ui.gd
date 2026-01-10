extends CanvasLayer

@onready var hp_label = $Label
@onready var money_label = $MoneyLabel
@onready var trade_window = $TradeWindow
@onready var trade_label = $TradeWindow/Label
@onready var repair_button = $TradeWindow/RepairButton

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("GameUI found player: ", player)
		# Update initial value
		_on_player_hp_changed(player.hp)
		_on_player_money_changed(player.money)
		
		# Connect signals
		if not player.hp_changed.is_connected(_on_player_hp_changed):
			player.hp_changed.connect(_on_player_hp_changed)
			print("Connected hp_changed signal")
		if not player.money_changed.is_connected(_on_player_money_changed):
			player.money_changed.connect(_on_player_money_changed)
	else:
		print("GameUI: Player not found in group 'player'")
			
	if repair_button:
		if not repair_button.pressed.is_connected(_on_repair_button_pressed):
			repair_button.pressed.connect(_on_repair_button_pressed)

func _on_player_hp_changed(new_hp):
	print("GameUI received hp_changed: ", new_hp)
	if hp_label:
		hp_label.text = "HP: " + str(new_hp)

func _on_player_money_changed(amount):
	if money_label:
		money_label.text = "$" + str(amount)

func _on_repair_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.change_money(-50):
			player.heal_full()
			print("Repaired!")
		else:
			print("Not enough cash!")

func on_port_entered(port_name):
	if trade_window:
		trade_window.visible = true
	if trade_label:
		trade_label.text = "Welcome to " + port_name

func on_port_exited():
	if trade_window:
		trade_window.visible = false
