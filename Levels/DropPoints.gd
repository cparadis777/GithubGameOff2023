extends Node2D

@export var n_horizontal:int
@export var n_vertical:int
@onready var drop_point:PackedScene = preload("res://Utilities/UtilityScenes/DropPoint.tscn")
var container_width:int = 128
var container_height:int = 64
@export var new_scale:float
var drop_points_dict:Dictionary
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
			var new_position:Vector2 = Vector2(i*0.5*self.container_width, j*self.container_height)
			var new_grid_position:Vector2 = Vector2(i,j)
			new_point.position = new_position
			new_point.set_grid_position(new_grid_position)
			drop_points_dict[new_grid_position] = new_point
			self.add_child(new_point)

func add_container(container:StaticBody2D, grid_position:Vector2) -> bool:
	var drop_point_to_use = self.drop_points_dict[grid_position]
	container.set_scale(Vector2(new_scale, new_scale))
	if drop_point_to_use.set_container(container):
		return true
	return false
	
