extends Node2D

@export var target_weight:int
@export var scene_path: String # GeneratedPlayspace.tscn
@export var has_tutorial:bool = true
var current_weight:int
var ignore_invalid_path : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.value = 0
	var fight_button = find_child("FightButton")
	if not fight_button.pressed.is_connected(_on_fight_button_pressed):
		fight_button.pressed.connect(_on_fight_button_pressed)

	await get_tree().create_timer(0.25).timeout
	#$Instructions/controls.popup()
	if self.has_tutorial:
		$"Instructions/Tutorial_AI".show()
	else:
		$crane.move_ready = true
	$HUD/WarningPopup.hide()
	$HUD/Panel/FightButton.disabled = true
	AudioManager.play_track("CraneLevelTheme")
	$DockSeaAmbient.play()


func add_weight(weight:int) -> void:
	self.current_weight += weight
	var new_percentage = Utils.normalize_value(self.current_weight, 0, target_weight)
	$ProgressBar.value = new_percentage

func _unhandled_input(event):
	press_escape_to_show_or_hide_tutorial(event)

func press_escape_to_show_or_hide_tutorial(event):
	if event.is_action_pressed("ui_cancel"):
		if has_node("Instructions/Tutorial_AI"):
			var tutorial = get_node("Instructions/Tutorial_AI")
			if tutorial != null and is_instance_valid(tutorial):
				if tutorial.visible:
					tutorial.stop_dialogue()
					get_viewport().set_input_as_handled()
	
		else: # tutorial bot disappeared
			if not $Instructions/controls.visible:
				$Instructions/controls.visible = true
				$crane.deactivate()
			else:
				$Instructions/controls.visible = false
				$crane.activate()
				

func _on_fight_button_pressed():
	if $DropPoints.validate_level() or ignore_invalid_path:
		StageManager.set_playspace_parameters($DropPoints.export_data())
		if scene_path != "":
			$AnimationPlayer.play("zoom_in")
			await $AnimationPlayer.animation_finished
			StageManager.change_scene_to(self.scene_path)
		else:
			printerr("ContainerStackingTest.gd config error: Needs a scene or scene_path parameter." + self.name)
	else:
		popup_invalid_level_warning()
		print("Invalid level")

func popup_invalid_level_warning():
	$HUD/WarningPopup.show()


	
func _on_drop_points_weight_reset():
	self.current_weight = 0
	self.add_weight(0)



func _on_tutorial_ai_finished():
	$crane.activate()


func _on_placement_instructions_finished():
	$crane.activate()


func _on_confirm_pressed():
	ignore_invalid_path = true
	_on_fight_button_pressed()


func _on_drop_points_drop_started():
	$HUD/Panel/ResetButton.disabled = true

func _on_drop_points_drop_over():
	$HUD/Panel/ResetButton.disabled = false



func _on_drop_points_valid_level():
	$HUD/Panel/FightButton.disabled = false


func _on_drop_points_invalid_level():
	$HUD/Panel/FightButton.disabled = true

