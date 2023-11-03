extends Button


@export var scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if !pressed.is_connected(self._on_pressed):
		pressed.connect(self._on_pressed)



func _on_pressed():
	if scene != null:
		StageManager.change_scene_to(scene)
	else:
		printerr("Scene Launch Button needs a Packed Scene in the scene parameter. " + self.name)
