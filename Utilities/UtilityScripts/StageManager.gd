extends Node

var current_level
var current_player

var beat_the_boss_screen : PackedScene = preload("res://CutScenes/BeatTheBoss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_scene_to(scene):
	if scene is PackedScene:
		# add some animated transitions later.
		get_tree().change_scene_to_packed(scene)

func _on_NPC_died(npc_name):
	if "boss" in npc_name.to_lower():
		end_game()
		
func end_game():
	change_scene_to(beat_the_boss_screen)
