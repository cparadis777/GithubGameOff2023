extends Node2D

const duration = 0.67 # seconds
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(queue_free)
	

func popup(text, color = Color.BLUE_VIOLET):
	if not text is String:
		text = str(text)
	$PanelContainer/Label.text = text
	set_panel_color(color)
	$Timer.start()
	var tween = create_tween()
	var rand_x = randi_range(-8, 8)
	tween.tween_property(self, "position", position + Vector2(rand_x,-32), duration)
	tween.parallel().tween_property(self, "scale", scale * 3.0, duration)

func set_panel_color(color):
	var new_stylebox = load("res://UI/Themes/popup_text_style_box_flat.tres")
	new_stylebox.bg_color = color
	$PanelContainer.add_theme_stylebox_override("normal", new_stylebox)

