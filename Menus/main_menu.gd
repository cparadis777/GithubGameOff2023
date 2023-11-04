extends Control

@export var game_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_button_audio()
	connect_button_signals()


func connect_button_audio():
	for container in $VBoxContainer/Body/MarginContainer/Body.get_children():
		if container is VBoxContainer:
			for button in container.get_children():
				button.mouse_entered.connect($Audio/HoverNoise.play)
				button.pressed.connect($Audio/ClickNoise.play)


func connect_button_signals():
	for button in %Buttons2.get_children():
#		if "play" in button.name.to_lower():
#			button.pressed.connect(start_game)
		if "quit" in button.name.to_lower():
			button.pressed.connect(quit_game)
		elif "settings" in button.name.to_lower():
			button.pressed.connect(view_settings)


func start_game():
	await get_tree().create_timer(0.5).timeout # wait for click audio
	if game_scene != null:
		get_tree().change_scene_to_packed(game_scene)
	else:
		printerr("Configuration error in main menu. game_scene parameter needs a packed scene.")
		printerr(get_tree().current_scene.scene_file_path)
		#get_tree().change_scene_to_file("res://Levels/placeholder/placeholder_2d_scene.tscn")


func quit_game():
	get_tree().quit()


func view_settings():
	await get_tree().create_timer(0.5).timeout # wait for click audio
	get_tree().change_scene_to_file("res://Menus/settings_menu.tscn")

