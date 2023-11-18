extends Node2D

@export var target_weight:int
@export var scene_path: String
var current_weight:int


# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.value = 0
	find_child("FightButton").pressed.connect(_on_fight_button_pressed)

	await get_tree().create_timer(1).timeout
	$Instructions/placement.popup()

func add_weight(weight:int) -> void:
	self.current_weight += weight
	var new_percentage = Utils.normalize_value(self.current_weight, 0, target_weight)
	$ProgressBar.value = new_percentage


func _on_fight_button_pressed():
	if $DropPoints.validate_level():
		StageManager.set_playspace_parameters($DropPoints.export_data())
		if scene_path != "":
			StageManager.change_scene_to(self.scene_path)
		else:
			printerr("ContainerStackingTest.gd config error: Needs a scene or scene_path parameter." + self.name)
	else:
		print("Invalid level")

func _on_drop_points_weight_reset():
	self.current_weight = 0
	self.add_weight(0)
