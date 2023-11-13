extends Node2D

const duration = 0.67 # seconds
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(queue_free)
	

func popup(text):
	if not text is String:
		text = str(text)
	$PanelContainer/Label.text = text
	$Timer.start()
	var tween = create_tween()
	var rand_x = randi_range(-8, 8)
	tween.tween_property(self, "position", position + Vector2(rand_x,-32), duration)
	tween.parallel().tween_property(self, "scale", scale * 3.0, duration)

