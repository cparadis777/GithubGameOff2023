extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	connect_button_audio()
	

func connect_button_audio():
	for button in $VBoxContainer/Body/LeftSide.get_children():
		button.mouse_entered.connect($Audio/HoverNoise.play)
		button.pressed.connect($Audio/ClickNoise.play)
		
		if "play" in button.name.to_lower():
			button.pressed.connect(start_game)
		elif "quit" in button.name.to_lower():
			button.pressed.connect(quit_game)
		elif "settings" in button.name.to_lower():
			button.pressed.connect(view_settings)


func start_game():
	await get_tree().create_timer(0.5).timeout # wait for click audio
	get_tree().change_scene_to_file("res://Levels/LevelTemplate.tscn")

func quit_game():
	get_tree().quit()

func view_settings():
	await get_tree().create_timer(0.5).timeout # wait for click audio
	get_tree().change_scene_to_file("res://Menus/settings_menu.tscn")
