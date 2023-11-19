extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_random_shit()


func spawn_random_shit():
	var shitList = $RandomShitToSpawn.get_resource_list()
	
	for i in range(randi_range(3,10)):
		var newThing = $RandomShitToSpawn.get_resource(shitList[randi()%shitList.size()])
		var newThingScene = newThing.instantiate()
		
		add_child(newThingScene)
		newThingScene.global_position = global_position
		newThingScene.position += Vector2(randi_range(-300, 300), randi_range(-256,0))
		
