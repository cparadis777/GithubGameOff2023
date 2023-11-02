extends Node2D

@export var n_horizontal:int
@export var n_vertical:int
@export var new_scale:float
@onready var drop_point:PackedScene = preload("res://Utilities/UtilityScenes/DropPoint.tscn")

var container_width:int = 128
var container_height:int = 64
var drop_points_dict:Dictionary
var current_position:Vector2 = Vector2(0,0)
var current_container

# Called when the node enters the scene tree for the first time.
func _ready():
	self.container_height = round(self.container_height * new_scale)
	self.container_width = round(self.container_width * new_scale)
	self.generate_drop_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generate_drop_points() -> void:
	for i in range(self.n_horizontal):
		for j in range(self.n_vertical):
			#TODO: Probably refactor so we generate the drop points around the center instead of from a corner
			var new_point:Marker2D = drop_point.instantiate()
			#var new_position:Vector2 = Vector2(i*0.5*self.container_width, j*0.5*self.container_height)
			var new_position:Vector2 = Vector2(i*self.container_width, j*self.container_height)
			var new_grid_position:Vector2 = Vector2(i,j)
			new_point.position = new_position
			new_point.set_grid_position(new_grid_position)
			drop_points_dict[new_grid_position] = new_point
			self.add_child(new_point)

func add_container(container:StaticBody2D, grid_position:Vector2) -> bool:
	var drop_point_to_use:Marker2D = self.get_drop_point(grid_position)
	container.set_scale(Vector2(new_scale, new_scale))
	if drop_point_to_use.set_container(container):
		return true
	return false
	
func get_adjacent_coordinate(direction:Utils.Directions, coordinate:Vector2 = self.current_position):
	match direction:
		0:
			if coordinate[1] > 0:
				return coordinate - Vector2(0,1)
			else: 
				return null
		1:
			if coordinate[0] < self.n_horizontal-1:
				return coordinate + Vector2(1,0)
			else: 
				return null
		2:
			if coordinate[1] < self.n_vertical-1:
				return coordinate + Vector2(0,1)
			else: 
				return null

		3:
			if coordinate[0] > 0:
				return coordinate - Vector2(1, 0)
			else: 
				return null
		

func move_container(direction:Utils.Directions) -> void:
	var next_position = self.get_adjacent_coordinate(direction)
	if next_position != null and self.current_container != null:
		if !self.get_drop_point(next_position).is_filled:
			self.current_position = next_position
			self.current_container.position = self.get_drop_point(current_position).position

func place_container() -> bool:
	get_parent().container_move_ready = false
	var falling:bool = true
	var position_to_place = self.current_position
	while falling:
		if check_under(position_to_place):
			position_to_place = get_adjacent_coordinate(Utils.Directions.DOWN, position_to_place)
		else:
			falling = false
	
	var drop_point_to_use:Marker2D = self.get_drop_point(position_to_place)
	self.current_container.set_mode("REAL")
	var tween = get_tree().create_tween()
	# v = d/t -> t = d/v
	var tween_time = self.current_position.distance_to(position_to_place)
	print(tween_time)
	tween.tween_property(self.current_container, "position", drop_point_to_use.position, tween_time)
	tween.tween_callback(drop_done)
	#self.current_container.set_position(drop_point_to_use.position)
	drop_point_to_use.set_container(self.current_container)
	self.current_container = null
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

func drop_done()->void:
	get_parent().container_move_ready = true
