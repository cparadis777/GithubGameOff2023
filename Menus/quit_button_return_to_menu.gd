#go back to the main menu when pressed

extends Button

func _on_pressed():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
