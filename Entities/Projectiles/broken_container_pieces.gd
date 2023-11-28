extends Node2D
enum container_types { BENGAL, ICE, EAGLE }
@export var type : container_types = container_types.BENGAL
var textures = {
	container_types.BENGAL: preload("res://art/low_res_containers/shipping_container_bengal_security-LOWRES.png"),
	container_types.ICE: preload("res://art/low_res_containers/shipping_container_ice_and_freezy_LOWRES.png"),
	container_types.EAGLE : preload("res://art/low_res_containers/shipping_container_ill_eagle-LOWRES.png"),
} 

# Called when the node enters the scene tree for the first time.
func _ready():
	$RigidBody2D/Left.texture = textures[type]
	$RigidBody2D2/Right.texture = textures[type]
	$SpawnTimer.start()
	



func spawn_enemy():
	var enemy_scenes = [
		preload("res://Entities/NPCs/new_runner.tscn"),
		preload("res://Entities/NPCs/shooty_npc.tscn"),
		preload("res://Entities/NPCs/npc_02_dock_worker.tscn"),
	]

	await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
	var new_enemy = enemy_scenes.pick_random().instantiate()
	get_tree().get_root().add_child(new_enemy)
	var distance = 32.0
	new_enemy.global_position = global_position + Vector2(randf_range(-distance,distance), randf_range(-distance,distance))
	new_enemy.activate()
	make_noise($EnemySpawnNoise)

func make_noise(audio_node : AudioStreamPlayer2D):
	var noise = audio_node.duplicate()
	noise.finished.connect(noise.queue_free)
	add_child(noise)
	noise.play()

func _on_spawn_timer_timeout():
	var max_enemies = 25
	if get_tree().get_nodes_in_group("Enemies").size() < max_enemies:
		
		for i in range(randi_range(3,5)):
			spawn_enemy()

		await get_tree().create_timer(5).timeout
		queue_free()
