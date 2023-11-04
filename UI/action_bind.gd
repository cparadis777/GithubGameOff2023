extends HBoxContainer

var action_name : String

enum States { DISPLAY, LISTEN }
var State = States.DISPLAY


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(incoming_event):
	if State == States.LISTEN and incoming_event is InputEventKey:
		replace_first_event_listener(incoming_event)


func replace_first_event_listener(incoming_event):
	var event_list = InputMap.action_get_events(action_name)
	for event in event_list:
		InputMap.action_erase_event(action_name, event )
	event_list[0] = incoming_event
	for event in event_list:
		InputMap.action_add_event(action_name, event)
	State = States.DISPLAY
	$KeybindButton.text = InputMap.action_get_events(action_name)[0].as_text()

func activate(actionName):
	action_name = actionName
	
	$ActionName.text = actionName
	$KeybindButton.text = InputMap.action_get_events(action_name)[0].as_text()


func _on_keybind_button_pressed():
	$KeybindButton.text = "..."
	State = States.LISTEN
