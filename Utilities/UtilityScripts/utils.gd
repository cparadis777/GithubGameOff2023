extends Node

enum DirectionFlags {NIL = 0, LEFT = 1, RIGHT = 2, UP = 4, DOWN = 8}

enum Directions {UP, RIGHT, DOWN, LEFT}

func get_opposite_direction(direction:Utils.Directions) -> Utils.Directions:
	match direction:
		Directions.UP:
			return Utils.Directions.DOWN
		Directions.RIGHT:
			return Utils.Directions.LEFT
		Directions.DOWN: 
			return Utils.Directions.UP
		Directions.LEFT: 
			return Utils.Directions.RIGHT
		_:
			return Utils.Directions.DOWN


func get_closest_node(nodeList : Array, location : Vector2):
	if not nodeList is Array: # received a single object?
		return nodeList

	var closest = null
	var closest_dist = 1000000
	for node in nodeList:
		if location.distance_squared_to(node.global_position) < closest_dist:
			closest = node
			closest_dist = location.distance_squared_to(node.global_position)
	return closest


func normalize_value(x, min_value, max_value) -> float: # for progress bars, etc.
	x = float(x)
	min_value = float(min_value)
	max_value = float(max_value)
	return (x-min_value)/(max_value-min_value)

func random_color() -> Color:
	return Color(randf(), randf(), randf())
