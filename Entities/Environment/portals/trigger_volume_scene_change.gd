extends Area2D

@export var next_scene : PackedScene = preload("res://Levels/BossFight/boss_fight.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_body_entered(body):
	if next_scene != null:
		if body.is_in_group("Player"):
			StageManager.change_scene_to(next_scene)
