extends Node2D

@export var target_weight:int
var current_weight:int


# Called when the node enters the scene tree for the first time.
func _ready():
	$Instructions/InfoPopup.hide()
	$ProgressBar.value = 0
	find_child("FightButton").pressed.connect(_on_fight_button_pressed)

	await get_tree().create_timer(1).timeout
	$Instructions/InfoPopup.popup()

func add_weight(weight:int) -> void:
	self.current_weight += weight
	var new_percentage = Utils.normalize_value(self.current_weight, 0, target_weight)
	$ProgressBar.value = new_percentage


func _on_fight_button_pressed():
	StageManager.set_playspace_parameters($DropPoints.export_data())
