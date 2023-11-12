extends Node

class_name ContainerData


@export var container_type:ContainerProperties.container_type
@export var container_exits:Dictionary = {Utils.Directions.UP: false, Utils.Directions.RIGHT: false, Utils.Directions.DOWN: false, Utils.Directions.LEFT: false}
@export var scene_path:String

func match_exits(exits:Dictionary) -> bool:
	for exit in exits:
		if self.container_exits[exit] == exits[exit]:
			pass
		else:
			return false
	return true

func match_type(type:ContainerProperties.container_type) -> bool:
	return type == self.container_type