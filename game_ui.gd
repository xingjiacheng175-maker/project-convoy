extends CanvasLayer

@onready var hp_label = $Label
@onready var trade_window = $TradeWindow
@onready var trade_label = $TradeWindow/Label

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Update initial value
		_on_player_hp_changed(player.hp)
		# Connect signal
		if not player.hp_changed.is_connected(_on_player_hp_changed):
			player.hp_changed.connect(_on_player_hp_changed)

func _on_player_hp_changed(new_hp):
	if hp_label:
		hp_label.text = "HP: " + str(new_hp)

func on_port_entered(port_name):
	if trade_window:
		trade_window.visible = true
	if trade_label:
		trade_label.text = "Welcome to " + port_name

func on_port_exited():
	if trade_window:
		trade_window.visible = false
