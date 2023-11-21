extends Node2D


func spawn_random_shit(num_objects):
	var obstacle_list
	for i in range(num_objects):
		if randf()<0.33:
			obstacle_list = $Floor
		else:
			obstacle_list = $Platforms
		obstacle_list.spawn_new_obstacle()
	
	

