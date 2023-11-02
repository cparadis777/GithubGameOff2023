extends Button


@export var scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_pressed():
	if scene != null:
		StageManager.change_scene_to(scene)
	else:
		printerr("Scene Launch Button needs a Packed Scene in the scene parameter. " + self.name)
