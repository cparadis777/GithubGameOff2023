extends StaticBody2D

# note: order of exit flags must match the order in Utils.DirectionFlags
@export_flags("LEFT", "RIGHT", "UP", "DOWN") var container_exit_flags:int = 15
@onready var exits_container_node

@export var doors_unlocked = false
@export var unlock_with_switch = false
@export var unlock_on_enemies_defeated = true
@export var show_exterior_on_start = true

@export var num_generated_objects:int = 0

var weight:int = 100
var grid_position:Vector2 = Vector2(100,100)
var type: ContainerProperties.container_type = ContainerProperties.container_type.BLUE
var num_enemies = 0

var has_entrance = {
	Utils.Directions.LEFT: false,
	Utils.Directions.UP: false,
	Utils.Directions.RIGHT: false,
	Utils.Directions.DOWN: false,
}

@onready var walls = {
	Utils.Directions.LEFT: $LeftCollision,
	Utils.Directions.UP: $TopCollision,
	Utils.Directions.RIGHT: $RightCollision,
	Utils.Directions.DOWN: $BottomCollision,
}

@onready var doors = {
	Utils.Directions.LEFT: "Exits/LEFT",
	Utils.Directions.UP: "Exits/UP",
	Utils.Directions.RIGHT: "Exits/RIGHT",
	Utils.Directions.DOWN: "Exits/DOWN",
}

# entrance_arrows:Dictionary = {Utils.Directions.LEFT: null}
# Called when the node enters the scene tree for the first time.

signal entered
signal exited


func _ready():
	if (show_exterior_on_start):
		$Exterior.visible = true
	else:
		$Exterior.visible = false
	
	if (has_node("Exits")):
		exits_container_node = $Exits
	else:
		pass #Tutorial scenes are still using deprecated containers. seems ok.
		#print_debug("using deprecated BaseContainer. Use res://Entities/Environment/Containers/LargeContainer.tscn instead")
	remove_unneeded_doors()
	
	if (has_node("SpawningLogic")):
		$SpawningLogic.spawn_random_shit(num_generated_objects)
	
	if has_node("ContainerInterior"):
		$ContainerInterior.show()
		$ContainerInterior.monitoring = true
		
	set_all_doors_locked(!doors_unlocked)
		
	await get_tree().create_timer(1.2).timeout
	if StageManager.current_player == null:
		spawn_player_for_testing()
		
	if has_node("ContainerInterior"):
		$ContainerInterior.show() # so level designers can hide the collision shape, but it'll work in-game
		
func _unhandled_input(event):
	if event.is_action_pressed("unlock_doors_cheat"):
		if $ContainerInterior.get_overlapping_bodies().has(get_tree().get_first_node_in_group("Player")):
			unlock_all_doors()
			get_viewport().set_input_as_handled()
		
func spawn_player_for_testing():
	print(self.name + ": No player detected, generating player scene. BaseContainer.gda")
	var player_scene_path = "res://Entities/Player/PlayerController.tscn"
	var player_node = load(player_scene_path).instantiate()
	add_child(player_node)
	player_node.position = Vector2(-350, 150)

	#spawn_canvas_modulate_for_better_lighting()
	
	
func spawn_canvas_modulate_for_better_lighting():
	# maybe better without the lighting?
	
	var canvasModulateScene = load("res://Entities/Environment/Lights/base_canvas_modulate.tscn").instantiate()
	add_child(canvasModulateScene)

func setup_backup_enemy_check():
	var timer = Timer.new()
	timer.name = "EnemyCheckTimer"
	timer.set_wait_time(1.0)
	add_child(timer)
	timer.timeout.connect(self.safety_check_to_unlock_empty_rooms)
	timer.start()



func remove_unneeded_doors():
	if container_exit_flags < 15:
		#print("found a container to check.")

		for exit in exits_container_node.get_children():
			# bitwise comparison math based on the name of the exit
			# exits must be named LEFT, RIGHT, UP, or DOWN for this to work
			if Utils.DirectionFlags[exit.name] & container_exit_flags:
				has_entrance[Utils.flag_to_direction(Utils.DirectionFlags[exit.name])] = true;
				exit.visible = true
				# print("has exit: %s" % exit.name)
			else:
				exit.queue_free()
		
func open_door(side:Utils.Directions):
	# change the sprite?
	# door_sprites[side]
	if has_entrance[side]:
		if has_node(doors[side]):
			get_node(doors[side]).locked = false

func set_all_doors_locked(locked):
	if locked == false:
		doors_unlocked = true
	for side in has_entrance:
		if has_node(doors[side]):
			get_node(doors[side]).locked = locked	

func unlock_all_doors():
	if !doors_unlocked:
		set_all_doors_locked(false)
		if has_node("OpeningDoorsVoice"):
			$OpeningDoorsVoice.play()
		else:
			printerr(self.name, " has no OpeningDoorsVoice node.")

func _on_switch_toggled(_pressed):
	if unlock_with_switch:
		unlock_all_doors()
	
func _on_NPC_died(_name):
	num_enemies -= 1;
	#print("enemies left: %d" % num_enemies)
	if (unlock_on_enemies_defeated and num_enemies <= 0):
		#print("container beaten")
		unlock_all_doors()


func safety_check_to_unlock_empty_rooms(): # from EnemyTimer.timeout, created in setup_backup_enemy_check()
	# for NPCs which don't inherit BaseNPC
	var local_enemies = get_local_entities("Enemies")
	if local_enemies.size() == 0 and unlock_on_enemies_defeated:
		unlock_all_doors()
		if has_node("EnemyCheckTimer"):
			$EnemyCheckTimer.stop()

func activate_npcs():
	for npc in get_local_entities("Enemies"):
		if npc.has_method("activate"):
			npc.activate()
		else:
			printerr("npc has no activate method: ", npc.name)

func activate_moving_platforms():
	for platform in get_local_entities("MovingPlatforms"):
		if platform.owner.has_method("activate"):
			platform.owner.activate()
		else:
			printerr("platform has no activate method: ", platform.name)

func get_local_entities(group_name):
	var entities = get_tree().get_nodes_in_group(group_name)
	var local_entities = []
	for entity in entities:
		if self.is_ancestor_of(entity):
			local_entities.push_back(entity)
	return local_entities

func _on_container_interior_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		# print("Showing outside container")
		$Exterior.show()

func _on_container_interior_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		# print("Hidden outside container")
		$Exterior.hide()
		activate_npcs()
		activate_moving_platforms()
		setup_backup_enemy_check()
		StageManager.current_container = self
		
		if body.has_method("_on_container_entered"):
			entered.connect(body._on_container_entered)
			entered.emit(self)
			entered.disconnect(body._on_container_entered)
