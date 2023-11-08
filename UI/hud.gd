extends CanvasLayer
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	player = owner
	$PauseMenu.hide()

func update_health_display(health_fraction_remaining : float):
	var hearts_available = $Control/HBoxContainer/HealthIcons.get_child_count()
	for heart in $Control/HBoxContainer/HealthIcons.get_children():
		if float(heart.get_index()) / float(hearts_available) < health_fraction_remaining:
			heart.show()
		else:
			heart.hide()
		


func _on_player_hurt():
	update_health_display(player.health / player.max_health)
	




