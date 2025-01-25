extends ColorRect

var player
var max_width = 100.0

func _ready() -> void:
	player = get_node("/root/game/PLAYER/player")

func _process(delta: float) -> void:
	var boost_percentage = player.get_boost_percentage()
	scale.x = boost_percentage / 100.0
