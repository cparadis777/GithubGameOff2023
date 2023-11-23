extends Sprite2D

@export var invert_switch: bool = false
var linked_object




func _on_switch_toggled(pressed):
	if !invert_switch:
		visible = pressed
	else:
		visible = !pressed

func _on_linked(linking_object):
	linked_object = linking_object
	
	_on_switch_toggled(linking_object.pressed)
