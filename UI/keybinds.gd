extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Actions.hide()
	$KeybindsButton.text = "> Controls"

	var actions = ["move_left", "move_right", "jump", "fast_punch", "strong_punch", "interact"]
	for action in actions:
		var container = $Actions/action_bind.duplicate()
				
			
		$Actions.add_child(container)
		container.show()
		container.activate(action)
		




func _on_keybinds_button_toggled(button_pressed):
	if button_pressed:
		$KeybindsButton.text = "v Controls"
	else:
		$KeybindsButton.text = "> Controls"
	
	$Actions.visible = !$Actions.visible 
	
	
