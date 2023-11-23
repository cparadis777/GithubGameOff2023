extends Marker2D

class_name DropPoint

var grid_position:Vector2
var is_filled:bool
var container:StaticBody2D
var neighbors = {
	Utils.Directions.LEFT:null,
	Utils.Directions.UP:null,
	Utils.Directions.RIGHT:null,
	Utils.Directions.DOWN:null,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_grid_position(coords:Vector2) -> void:
	self.grid_position = coords

func set_container(new_container:StaticBody2D) -> bool:
	if !self.is_filled:
		self.container = new_container
		self.is_filled = true
		return true
	else:
		return false

func set_neighbors() -> void:
	for direction in neighbors:
		var coordinate_to_check = get_parent().get_adjacent_coordinate(direction, self.grid_position)
		if coordinate_to_check != null:
			var neighboring_drop_point = get_parent().drop_points_dict[coordinate_to_check]
			self.neighbors[direction] = neighboring_drop_point

func remove_container() -> void:
	if self.is_filled:
		self.container.queue_free()
		self.container = null
		self.is_filled = false
