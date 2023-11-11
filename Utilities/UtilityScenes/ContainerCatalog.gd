extends Node

@export var debug_mode:bool

func generate_playspace(playspace_parameters:Dictionary) -> Dictionary:
	var playspace = {}

	for coordinate in playspace_parameters:
		var container_properties = playspace_parameters[coordinate]
		var type:ContainerProperties.container_type = container_properties["type"]
		var exits:Dictionary = container_properties["exits"]

		var valid_containers:Array[ContainerData] = self.get_valid_containers(type, exits)

		if valid_containers.size() == 0:
			push_error("No container respects criterions")
		var chosen_container:ContainerData = valid_containers.pick_random()

		playspace[coordinate] = chosen_container

	return playspace


func get_valid_containers(type:ContainerProperties.container_type, exits:Dictionary) -> Array[ContainerData]:
	var valid_containers:Array[ContainerData] = []
	for container in self.get_children():
		if container.match_type(type) or self.debug_mode:
			if container.match_exits(exits) or self.debug_mode:
				valid_containers.append(container)
	print(valid_containers)
	return valid_containers
