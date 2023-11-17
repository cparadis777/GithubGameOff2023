extends Node

class_name ContainerData


@export var container_type:ContainerProperties.container_type
@export_flags("Left", "Right", "Up", "Down") var container_exit_flags:int = Utils.DirectionFlags.NIL
@export_multiline var scene_path:String

var container_exits:Dictionary = {Utils.Directions.UP: false, Utils.Directions.RIGHT: false, Utils.Directions.DOWN: false, Utils.Directions.LEFT: false}

func _ready():
	if (container_exit_flags & Utils.DirectionFlags.LEFT):
		container_exits[Utils.Directions.LEFT] = true;
	if (container_exit_flags & Utils.DirectionFlags.RIGHT):
		container_exits[Utils.Directions.RIGHT] = true;
	if (container_exit_flags & Utils.DirectionFlags.UP):
		container_exits[Utils.Directions.UP] = true;
	if (container_exit_flags & Utils.DirectionFlags.DOWN):
		container_exits[Utils.Directions.DOWN] = true;

func match_exits(exits:Dictionary) -> bool:
	for exit in exits:
		if self.container_exits[exit] == exits[exit]:
			pass
		else:
			return false
	return true

func match_type(type:ContainerProperties.container_type) -> bool:
	return type == self.container_type
