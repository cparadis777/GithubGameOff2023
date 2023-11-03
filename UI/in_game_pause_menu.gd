extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("pause"):
		toggle_pause()
	
func toggle_pause():

	if get_tree().is_paused():
		hide()
		get_tree().paused = false
	else:
		show()
		get_tree().paused = true


func _on_resume_button_pressed():
	toggle_pause()
