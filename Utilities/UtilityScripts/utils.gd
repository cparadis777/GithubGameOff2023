extends Node

enum Directions {UP, RIGHT, DOWN, LEFT}


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


func normalize_value(x, min_value, max_value) -> float:
	x = float(x)
	min_value = float(min_value)
	max_value = float(max_value)
	return (x-min_value)/(max_value-min_value)
