extends Area2D

@export var next_scene_path : String = "res://Entities/ContainerStackingTest.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if player_present() != null:
			StageManager.change_scene_to(next_scene_path)
			get_viewport().set_input_as_handled()


func player_present():
	var player_body = null
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			player_body = body
	return player_body
