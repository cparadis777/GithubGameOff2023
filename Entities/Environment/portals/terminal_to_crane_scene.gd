extends Area2D

@export var crane_scene_basepath : String = "res://Levels/StackingLevels/StackLevel"
var crane_scene_extension : String = ".tscn"
@export var this_level_number : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if player_present() != null:
			Globals.player_stats["completed_levels"].push_back(this_level_number)
			StageManager.change_scene_to(crane_scene_basepath + str(this_level_number+1) + crane_scene_extension)
			get_viewport().set_input_as_handled()


func player_present():
	var player_body = null
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			player_body = body
	return player_body
