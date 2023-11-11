extends Grid


@export var new_scale:float
@onready var drop_point:PackedScene = preload("res://Utilities/UtilityScenes/DropPoint.tscn")

var container_dropping
var drop_points_dict:Dictionary
var drop_point_targeted

signal weight_added(weight)
signal drop_over

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
			var new_position:Vector2 = Vector2(i*self.container_width, j*self.container_height)
			var new_grid_position:Vector2 = Vector2(i,j)
			new_point.position = new_position
			new_point.set_grid_position(new_grid_position)
			drop_points_dict[new_grid_position] = new_point
			self.add_child(new_point)
	for coordinate in drop_points_dict:
		drop_points_dict[coordinate].set_neighbors()

func add_container(container:StaticBody2D, grid_position:Vector2) -> bool:
	var drop_point_to_use:Marker2D = self.get_drop_point(grid_position)
	container.set_scale(Vector2(new_scale, new_scale))
	if drop_point_to_use.set_container(container):
		return true
	return false
	


func place_container(container:StaticBody2D, column:int) -> bool:
	var falling:bool = true
	var current_position = Vector2(column, 0)
	var position_to_place = current_position
	while falling:
		if check_under(position_to_place):
			position_to_place = get_adjacent_coordinate(Utils.Directions.DOWN, position_to_place)
		else:
			falling = false
	
	var drop_point_to_use:Marker2D = self.get_drop_point(position_to_place)
	var tween = get_tree().create_tween()
	# v = d/t -> t = d/v
	var tween_time = container.global_position.distance_to(drop_point_to_use.global_position)/100
	tween.tween_property(container, "global_position", drop_point_to_use.global_position, tween_time).set_trans(tween.TRANS_QUAD).set_ease(tween.EASE_IN)
	tween.tween_callback(drop_done)
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

func drop_done()->void:
	var old_parent = self.container_dropping.get_parent()
	old_parent.remove_child(self.container_dropping)
	self.drop_point_targeted.add_child(self.container_dropping)
	self.container_dropping.position = (Vector2(0,0))
	emit_signal("weight_added", self.container_dropping.weigth)
	emit_signal("drop_over")


func check_drop_possible(column:int) -> bool:
	return !get_drop_point(Vector2(column,0)).is_filled
