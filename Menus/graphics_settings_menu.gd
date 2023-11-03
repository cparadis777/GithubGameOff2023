extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_fullscreen_check_button_toggled(button_pressed):
	var window = get_window()
	print(window.name)
	if button_pressed == true:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
