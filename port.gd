extends Area2D

signal player_entered_port(port_node)
signal player_exited_port

@export var port_name: String = "Port Royal"
@export var buy_price: int = 10
@export var sell_price: int = 50

func _ready():
	# Connect signals if not connected via editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_entered_port.emit(self)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_exited_port.emit()
