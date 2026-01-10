extends CanvasLayer

@onready var hp_label = $Label

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
