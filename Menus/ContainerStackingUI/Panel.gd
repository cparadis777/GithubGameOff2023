extends TextureRect


func _ready():
	connect_button_audio()
	
func connect_button_audio():
	for button in get_children():
		if button is Button or button is TextureButton:
			button.pressed.connect($Audio/ClickNoise.play)
			#button.mouse_entered.connect($Audio/HoverNoise.play)
			
	
func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

