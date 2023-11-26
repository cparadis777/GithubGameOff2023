extends TextureRect


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
