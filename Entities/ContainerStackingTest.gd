extends Node2D

@export var target_weight:int
var current_weight:int


# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.value = 0

func add_weight(weight:int) -> void:
	self.current_weight += weight
	var new_percentage = Utils.normalize_value(self.current_weight, 0, target_weight)
	$ProgressBar.value = new_percentage


func _on_quit_button_return_to_menu_pressed():
	StageManager.set_playspace_parameters($DropPoints.export_data())
