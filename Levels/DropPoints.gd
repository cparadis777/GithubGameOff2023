extends Grid


@export var entrance_coord:Vector2
@export var exit_coord:Vector2
@export var entrance_direction:Utils.Directions
@export var exit_direction:Utils.Directions

@onready var drop_point:PackedScene = preload("res://Utilities/UtilityScenes/DropPoint.tscn")

var container_dropping
var drop_points_dict:Dictionary
var drop_point_targeted

signal weight_added(weight)
signal drop_over
signal weight_reset()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.generate_drop_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generate_drop_points() -> void:
	for i in range(self.n_horizontal):
		for j in range(self.n_vertical):
			var new_point:Marker2D = drop_point.instantiate()
			var new_position:Vector2 = Vector2(i*self.container_width, -j*self.container_height)
			var new_grid_position:Vector2 = Vector2(i,j)
			new_point.position = new_position
			new_point.set_grid_position(new_grid_position)
			drop_points_dict[new_grid_position] = new_point
			self.add_child(new_point)
	for coordinate in drop_points_dict:
		drop_points_dict[coordinate].set_neighbors()

func add_container(container:StaticBody2D, grid_position:Vector2) -> bool:
	var drop_point_to_use:Marker2D = self.get_drop_point(grid_position)
	if drop_point_to_use.set_container(container):
		return true
	return false
	

func place_container(container:StaticBody2D, column:int) -> bool:
	var falling:bool = true
	var current_position = Vector2(column, self.n_vertical-1)
	var position_to_place = current_position
	while falling:
		if check_under(position_to_place):
			position_to_place = get_adjacent_coordinate(Utils.Directions.DOWN, position_to_place)
		else:
			falling = false
	
	var drop_point_to_use:Marker2D = self.get_drop_point(position_to_place)
	var tween = get_tree().create_tween()
	tween.finished.connect(drop_done)
	# v = d/t -> t = d/v
	var tween_time = container.global_position.distance_to(drop_point_to_use.global_position)/100
	tween.tween_property(container, "global_position", drop_point_to_use.global_position, tween_time).set_trans(tween.TRANS_QUAD).set_ease(tween.EASE_IN)
	drop_point_to_use.set_container(container)
	self.container_dropping = container
	self.drop_point_targeted = drop_point_to_use

	return true

func get_drop_point(coord:Vector2):
	if self.drop_points_dict.has(coord):
		return self.drop_points_dict[coord]
	else:
		push_error("Tried to access inexistant drop point")

func set_current_container(container:StaticBody2D) -> void:
	self.current_container = container
	self.current_container.set_scale(Vector2(self.new_scale, self.new_scale))
	self.current_container.set_mode("GHOST")
	self.current_position = Vector2(0,0)
	self.add_child(self.current_container)
	
func check_under(coordinate:Vector2) -> bool:
	var coordinate_under = self.get_adjacent_coordinate(Utils.Directions.DOWN, coordinate)
	if coordinate_under == null:
		return false
	var drop_point_underneath = self.get_drop_point(coordinate_under)
	if !drop_point_underneath.is_filled:
		return true
	return false

func drop_done() -> void:
	$BangNoise.play()
	var old_parent = self.container_dropping.get_parent()
	old_parent.remove_child(self.container_dropping)
	self.drop_point_targeted.add_child(self.container_dropping)
	self.container_dropping.position = (Vector2(0,0))
	self.validate_level()
	var tween = get_tree().create_tween()
	tween.tween_property(container_dropping, "position", Vector2(0, -5), 0.2).set_ease(tween.EASE_OUT)
	tween.tween_property(container_dropping, "position", Vector2(0,0), 0.1)

	emit_signal("weight_added", self.container_dropping.weigth)
	emit_signal("drop_over")



func check_drop_possible(column:int) -> bool:
	return !get_drop_point(Vector2(column,self.n_vertical-1)).is_filled


func export_data() -> Dictionary:
	var data = {}

	self.check_unneeded_exits()

	data["shape"] = Vector2(self.n_horizontal, self.n_vertical)
	var containers = {}
	for coordinate in self.drop_points_dict:
		if self.drop_points_dict[coordinate].container != null:
			var type = self.drop_points_dict[coordinate].container.type
			var exits = self.drop_points_dict[coordinate].container.entrances
			containers[coordinate] = {"type": type, "exits": exits}
		
	data["containers"] = containers
	return data


func validate_level() -> bool:
	var entrance_drop_point:DropPoint = self.get_drop_point(self.entrance_coord)
	var exit_drop_point:DropPoint = self.get_drop_point(self.exit_coord)

	if entrance_drop_point.container == null || exit_drop_point.container == null:
		return false
	
	if entrance_drop_point.container != null:
		if entrance_drop_point.container.entrances[self.entrance_direction] == false:
			return false
	if exit_drop_point.container != null:
		if exit_drop_point.container.entrances[self.exit_direction] == false:
			return false
	
	if entrance_drop_point.container != null:
		return self.path_search()

	return true


func path_search() -> bool:
	var start:Vector2 = self.entrance_coord
	var visited_nodes = {}
	var visited_node_count = 0
	
	for coord in drop_points_dict:
		visited_nodes[coord] = false

	var queue:Array = [start]
	visited_nodes[start] = true

	while queue.size() != 0:
		visited_node_count += 1
		var node = queue.pop_front()
		if node == self.exit_coord:
			return true
		var current_drop_point = self.drop_points_dict[node]
		if current_drop_point.is_filled: # Check if there is a container in the current slot
			for direction in current_drop_point.neighbors: # Iterate over all the neighbor slot of the current slot
				if current_drop_point.container.entrances[direction]: #Check if the current container has an exit towards the current direction
					if current_drop_point.neighbors[direction] != null: #Check if the neighboring slot exists
						if current_drop_point.neighbors[direction].is_filled: #Check if the neighboring slot has a container
							var opposite_direction = Utils.get_opposite_direction(direction)
							if current_drop_point.neighbors[direction].container.entrances[opposite_direction]: #Check if reciprocal entrance exists in neighbor
								var neighbor_coord = current_drop_point.neighbors[direction].grid_position 
								if visited_nodes[neighbor_coord] != true: #Check if we already visited that node
									visited_nodes[neighbor_coord] = true #Mark that node as visited
									queue.append(neighbor_coord) #Add that node to the queue
	return false


func get_neighbors_coordinate(coordinate:Vector2) -> Array:
	var neighbors = []
	var directions = [Utils.Directions.LEFT, Utils.Directions.UP, Utils.Directions.RIGHT, Utils.Directions.DOWN]
	for direction in directions:
		neighbors.append(self.get_adjacent_coordinate(direction, coordinate))
	return neighbors


func reset_dropped_containers()->void:
	for coord in self.drop_points_dict:
		drop_points_dict[coord].remove_container()
	emit_signal("weight_reset")

func check_unneeded_exits() ->void:
	for coord in self.drop_points_dict:
		var current_drop_point:DropPoint = self.drop_points_dict[coord]
		for direction in current_drop_point.neighbors:
			if current_drop_point.is_filled:
				if current_drop_point.neighbors[direction] == null:
					if current_drop_point.container.entrances[direction]:
						current_drop_point.container.entrances[direction] = false
						print("Removed %s from %s" % [Utils.Directions.keys()[direction], coord])
				elif current_drop_point.neighbors[direction].is_filled == false:
					if current_drop_point.container.entrances[direction]:
						current_drop_point.container.entrances[direction] = false
						print("Removed %s from %s" % [Utils.Directions.keys()[direction], coord])
				elif current_drop_point.neighbors[direction].container.entrances[Utils.get_opposite_direction(direction)] == false:
					if current_drop_point.container.entrances[direction]:
						current_drop_point.container.entrances[direction] = false
						print("Removed %s from %s" % [Utils.Directions.keys()[direction], coord])
		if coord == self.entrance_coord:
			current_drop_point.container.entrances[self.entrance_direction] = true
			print("Added back %s to %s" % [Utils.Directions.keys()[self.entrance_direction], coord])
		if coord == self.exit_coord:
			current_drop_point.container.entrances[self.exit_direction] = true 
			print("Added back %s to %s" % [Utils.Directions.keys()[self.exit_direction], coord])
		
		# print(current_drop_point.container.entrances)
