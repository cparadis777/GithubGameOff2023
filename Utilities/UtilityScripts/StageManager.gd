extends Node

var current_level
var current_player
var playspace_parameters: Dictionary

var beat_the_boss_screen : PackedScene = preload("res://CutScenes/BeatTheBossWinCutscene.tscn")
var player_dead_scene: PackedScene = preload("res://CutScenes/PlayerDeadLoseCutscene.tscn")

var current_fight_level_idx = null
var current_stack_level_idx = null


var stacklevels = [
				preload("res://Levels/StackingLevels/StackingLevel1.tscn"),
				preload("res://Levels/StackingLevels/StackingLevel2.tscn")
				]
var fightlevels = [
				preload("res://Levels/FightingLevels/FightLevel1.tscn"),
				preload("res://Levels/FightingLevels/FightLevel2.tscn")
				]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func change_scene_to(scene):
	if scene is PackedScene:
		# add some animated transitions later.
		get_tree().change_scene_to_packed(scene)
	elif scene is String:
		get_tree().change_scene_to_file(scene)


func _on_NPC_died(npc_name):
	if "boss" in npc_name.to_lower():
		increase_difficulty()
		end_game("win")

func increase_difficulty():
	Globals.difficulty = min(Globals.difficulty + 1, Globals.DifficultyScales.keys().size()-1) # in case they want to play again


func _on_player_dead_and_buried():
	#end_game("lose") # seems a bit harsh
	reset_playspace()
	
func end_game(status):
	match status:
		"win":
			change_scene_to(beat_the_boss_screen)
		"lose":
			change_scene_to(player_dead_scene)

func reset_playspace():
#	if get_tree().get_root().has_node("GeneratedPlayspace"):
#		var playspace = get_tree().get_root().get_node("GeneratedPlayspace")
#		playspace.reset()
	
	change_scene_to(stacklevels[current_stack_level_idx])
		
	
func set_playspace_parameters(data:Dictionary) -> void:
	self.playspace_parameters = data

	#Form of playspace_parameters: 4-deep nested dictionary.
	#{
	#	shape: Vector2(n,m),
	#	containers: {
	#		Vector2(x,y): {
	#			type: ContainerProperties.container_type, exits: {
	#					Utils.Directions: bool
	#			}
	#		}	
	#	}
	#}



func popup_text(text, location : Vector2, color):
	var newPopup = preload("res://Entities/Environment/Popups/popup_numbers.tscn").instantiate()
	newPopup.global_position = location
	add_child(newPopup)
	newPopup.popup(text, color)

func _on_damage_packet_processed(attackPacket: AttackPacket):
	# the recipient forwards the packet to Stage Manager AFTER they fill in values for blocked damage
	var location = attackPacket.recipient.global_position + Vector2(0,-40)
	var color
	if attackPacket.recipient == current_player:
		color = Color.DARK_RED
	else:
		color = Color.BLUE_VIOLET
	var damage_to_display = attackPacket.damage - attackPacket.damage_blocked
	
	popup_text(str(damage_to_display).pad_decimals(0), location, color)

func change_to_next_fight_scene():
	if self.current_fight_level_idx == null:
		self.current_fight_level_idx = 0
		change_scene_to(self.fightlevels[self.current_fight_level_idx])
	else:
		self.current_fight_level_idx += 1
		change_scene_to(self.fightlevels[self.current_fight_level_idx])

func change_to_next_stack_scene():
	if self.current_stack_level_idx == null:
		self.current_stack_level_idx = 0
		change_scene_to(self.stacklevels[self.current_stack_level_idx])
	self.current_stack_level_idx += 0
	change_scene_to(self.stacklevels[self.current_stack_level_idx])
