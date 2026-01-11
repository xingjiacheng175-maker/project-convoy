extends Area2D

signal player_entered_port(port_node)
signal player_exited_port
signal discovered(port_node)

const ITEM_DB = {
	"Spice": 10,
	"Machinery": 50,
	"Alloy": 30,
	"Contraband": 200
}

@export var export_item_name: String = ""
@export var port_name: String = "Port Royal"
@export var buy_price: int = 10
@export var sell_price: int = 50

var is_discovered = false
var discovery_radius = 600.0
var available_mission = {}

func _ready():
	add_to_group("ports")
	
	# Connect signals if not connected via editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
		
	# Create Port Light
	var light = PointLight2D.new()
	var gradient_tex = GradientTexture2D.new()
	var gradient = Gradient.new()
	
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(0, 0, 0, 0)])
	gradient_tex.gradient = gradient
	gradient_tex.width = 256
	gradient_tex.height = 256
	gradient_tex.fill = GradientTexture2D.FILL_RADIAL
	gradient_tex.fill_from = Vector2(0.5, 0.5)
	gradient_tex.fill_to = Vector2(0.5, 0.0)
	
	light.texture = gradient_tex
	light.color = Color(1, 0.8, 0.4)
	light.energy = 1.0
	add_child(light)
	
	generate_mission()

func get_market_data() -> Dictionary:
	var market = {}
	for item in ITEM_DB.keys():
		var base_price = ITEM_DB[item]
		if item == export_item_name:
			market[item] = {"price": base_price, "is_selling": true}
		else:
			market[item] = {"price": base_price * 2, "is_selling": false}
	return market

func generate_mission():
	var ports = get_tree().get_nodes_in_group("ports")
	if ports.size() <= 1:
		return # No other ports
		
	var target_port = null
	while target_port == null or target_port == self:
		target_port = ports.pick_random()
		
	var dist = global_position.distance_to(target_port.global_position)
	var reward = int(dist * 0.5)
	
	available_mission = {
		"target_name": target_port.port_name,
		"target_node": target_port,
		"reward": reward
	}
	print("Mission Generated at ", port_name, ": To ", available_mission.target_name, " Reward: ", reward)

func _process(delta):
	if not is_discovered:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var dist = global_position.distance_to(player.global_position)
			if dist < discovery_radius:
				is_discovered = true
				discovered.emit(self)
				print("Port Discovered: ", port_name)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_entered_port.emit(self)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_exited_port.emit()
