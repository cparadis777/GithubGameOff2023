extends Button


@export var scene : PackedScene
@export var scene_path : String

# Called when the node enters the scene tree for the first time.
func _ready():
	if !pressed.is_connected(self._on_pressed):
		pressed.connect(self._on_pressed)



func _on_pressed():
	
	if scene != null:
		StageManager.change_scene_to(scene)
	elif scene_path != "":
		StageManager.change_scene_to(scene_path)
	else:
		printerr("scene_launch_button.gd config error: Needs a scene or scene_path parameter. " + self.name)
