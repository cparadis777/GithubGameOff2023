extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/HBoxContainer/MainMenuButton.pressed.connect(return_to_main)
	$PauseMenu.hide()


		
	



func return_to_main():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")



