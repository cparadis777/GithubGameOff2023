extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func focus_on_player():
	# not really needed, with the camera drag settins.
	pass
	
#	var tween = create_tween()
#
#	tween.tween_property(self, "offset", offset + Vector2.DOWN * 90, 0.3)
#	tween.tween_property(self, "offset", offset, 1.0)


func _on_player_jumped():
	focus_on_player()
