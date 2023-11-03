extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Actions.hide()
	$KeybindsButton.text = "> Controls"

	var actions = ["move_left", "move_right", "jump", "punch", "kick", "shoot"]
	for action in actions:
		var container = $Actions/action_bind.duplicate()
				
			
		$Actions.add_child(container)
		container.show()
		container.activate(action)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_keybinds_button_toggled(button_pressed):
	if button_pressed:
		$KeybindsButton.text = "v Controls"
	else:
		$KeybindsButton.text = "> Controls"
	
	$Actions.visible = !$Actions.visible 
	
	
