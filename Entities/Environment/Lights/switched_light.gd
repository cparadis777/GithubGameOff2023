extends Light2D

@export var inverse : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_switch_toggled(pressed):
	if inverse:
		visible = !pressed
	else:
		visible = pressed
