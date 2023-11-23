extends Node2D

@export var container_node : Node2D



func spawn_new_obstacle():
	var resource_names : Array = $SpawnList.get_resource_list() as Array
	var rand_resource_name = resource_names.pick_random()
	var new_obstacle_scene = $SpawnList.get_resource(rand_resource_name)
	var new_obstacle_node = new_obstacle_scene.instantiate()
	if container_node != null:
		container_node.add_child(new_obstacle_node)
	else:
		add_sibling(new_obstacle_node)
	var spawn_zone = $SpawnZone.get_rect()
	new_obstacle_node.global_position = $SpawnZone.global_position + Vector2(randi_range(0, spawn_zone.size.x), randi_range(0, spawn_zone.size.y))
	
