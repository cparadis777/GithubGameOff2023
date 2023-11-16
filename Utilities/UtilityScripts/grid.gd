extends Node2D

class_name Grid

@export var n_horizontal:int
@export var n_vertical:int
@export var container_width:int = 96
@export var container_height:int = 48

func get_adjacent_coordinate(direction:Utils.Directions, coordinate:Vector2 = self.current_position):
	match direction:
		Utils.Directions.DOWN:
			if coordinate[1] > 0:
				return coordinate - Vector2.DOWN
			else: 
				return null
		Utils.Directions.RIGHT:
			if coordinate[0] < self.n_horizontal-1:
				return coordinate + Vector2.RIGHT
			else: 
				return null
		Utils.Directions.UP:
			if coordinate[1] < self.n_vertical-1:
				return coordinate + Vector2.DOWN
			else: 
				return null
		Utils.Directions.LEFT:
			if coordinate[0] > 0:
				return coordinate - Vector2.RIGHT
			else: 
				return null
