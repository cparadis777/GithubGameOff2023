extends Node

enum Directions {UP, RIGHT, DOWN, LEFT}


func get_closest_node(nodeList : Array, location : Vector2):
	var closest = null
	var closest_dist = 1000000
	for node in nodeList:
		if location.distance_squared_to(node) < closest_dist:
			closest = node
			closest_dist = location.distance_squared_to(node)
	return closest


func normalize(x, min, max) -> float:
	x = float(x)
	min = float(min)
	max = float(max)
	return (x-min)/(max-min)
