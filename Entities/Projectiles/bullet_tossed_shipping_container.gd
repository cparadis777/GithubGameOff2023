extends RigidBody2D

enum container_types { BENGAL, ICE, EAGLE }
@export var types : container_types = container_types.BENGAL
var textures = {
	container_types.BENGAL: preload("res://art/low_res_containers/shipping_container_bengal_security-LOWRES.png"),
	container_types.ICE: preload("res://art/low_res_containers/shipping_container_ice_and_freezy_LOWRES.png"),
	container_types.EAGLE : preload("res://art/low_res_containers/shipping_container_ill_eagle-LOWRES.png"),
} 
var container_type : container_types
var dropped : bool = false
var at_rest : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	container_type = container_types.values().pick_random()
	$ContainerExteriorSprite.texture = textures[container_type]

func _physics_process(_delta):
	if dropped and linear_velocity.is_zero_approx() and !at_rest:
		create_static_platform_from_rigid_body()


func create_static_platform_from_rigid_body():
	at_rest = true
	freeze = true
	$PlayerDetector.collision_layer = 0
	$PlayerDetector.collision_mask = 0
	self.collision_layer = 0 # allow player to pass
	$PlayerDetector.monitoring = false
	spawn_platform()
	$Shadow.hide()
	for i in range(randi_range(0, 3)):
		spawn_enemy()

func make_noise(audio_node : AudioStreamPlayer2D):
	var noise = audio_node.duplicate()
	noise.finished.connect(noise.queue_free)
	add_child(noise)
	noise.play()


func spawn_platform():
	var platform_scene = preload("res://Levels/BossFight/platforms/spawn_platform_for_top_of_container.tscn").instantiate()
	add_child(platform_scene)
	platform_scene.global_position = global_position
	make_noise($BangNoise)

func spawn_enemy():
	var enemy_scenes = [
		preload("res://Entities/NPCs/new_runner.tscn"),
		preload("res://Entities/NPCs/shooty_npc.tscn"),
		preload("res://Entities/NPCs/npc_02_dock_worker.tscn"),
	]

	await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
	var new_enemy = enemy_scenes.pick_random().instantiate()
	get_tree().get_root().add_child(new_enemy)
	var jitter_distance = 32.0
	var jitterVec = Vector2(randf_range(-jitter_distance,jitter_distance), randf_range(-jitter_distance,jitter_distance))
	var rand_direction = [-1, 1].pick_random()
	var spawn_point = global_position + (Vector2.ONE * 76) * rand_direction
	new_enemy.global_position = spawn_point + jitterVec
	new_enemy.activate()
	make_noise($EnemySpawnNoise)


func spawn_pieces(body):
	var num_max_containers = 10
	var num_current_containers = get_tree().get_nodes_in_group("BossContainers").size()
	if num_current_containers < num_max_containers:
		var pieces = preload("res://Entities/Projectiles/broken_container_pieces.tscn").instantiate()
		pieces.container_type = container_type
		call_deferred("add_sibling", pieces)
		pieces.set_deferred("global_position", global_position)
		pieces.set_deferred("global_rotation", global_rotation)
		pieces.call_deferred("activate", container_type, body)


func _on_player_detector_body_entered(body):
	#super(body) # cause damage to player
	if body.is_in_group("Player"):
		# crack open and spawn enemies
		spawn_pieces(body)
		call_deferred("queue_free")


func _on_timer_timeout():
	pass # Replace with function body.


func _on_start_timer_timeout():
	# prevent process from freezing the container immediately when spawned.
	# grace period before calling it dropped.
	dropped = true
