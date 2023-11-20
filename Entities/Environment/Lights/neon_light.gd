extends Sprite2D

@export var invert_switch: bool = false
var linked_object

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_switch_toggled(pressed):
	if !invert_switch:
		visible = pressed
	else:
		visible = !pressed

func _on_linked(linking_object):
	linked_object = linking_object
	
	_on_switch_toggled(linking_object.pressed)
