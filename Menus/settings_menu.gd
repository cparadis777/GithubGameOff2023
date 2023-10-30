extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%ReturnToMainButton.pressed.connect(return_to_main)
	%GraphicsModeOptionList.selected = Globals.user_prefs["graphics"]

func return_to_main():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _on_fullscreen_check_button_toggled(button_pressed):
	var window = get_window()
	if button_pressed == true:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED




func _on_graphics_mode_option_list_item_selected(index):
	Globals.user_prefs["graphics"] = index
	if has_node("Background") and get_node("Background").has_method("_on_graphics_toggled"):
		$Background._on_graphics_toggled()
