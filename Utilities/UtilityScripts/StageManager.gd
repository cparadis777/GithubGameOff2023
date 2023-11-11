extends Node

var current_level
var current_player

var beat_the_boss_screen : PackedScene = preload("res://CutScenes/BeatTheBoss.tscn")
var player_dead_scene: PackedScene = preload("res://CutScenes/PlayerDead.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_scene_to(scene):
	if scene is PackedScene:
		# add some animated transitions later.
		get_tree().change_scene_to_packed(scene)

func _on_NPC_died(npc_name):
	if "boss" in npc_name.to_lower():
		end_game("win")

func _on_player_dead_and_buried():
	end_game("lose")
	
func end_game(status):
	match status:
		"win":
			change_scene_to(beat_the_boss_screen)
		"lose":
			change_scene_to(player_dead_scene)
