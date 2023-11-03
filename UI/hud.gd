extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/HBoxContainer/MainMenuButton.pressed.connect(return_to_main)
	$PauseMenu.hide()


		
	
func _physics_process(delta):
	pass
#	if Input.is_action_just_released("pause"):
#		toggle_pause()
#
#func toggle_pause():
#
#	if get_tree().is_paused():
#		$PauseMenu.hide()
#		get_tree().paused = false
#	else:
#		$PauseMenu.show()
#		get_tree().paused = true


func return_to_main():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")



