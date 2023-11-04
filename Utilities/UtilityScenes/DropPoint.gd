extends Marker2D

var grid_position:Vector2
var is_filled:bool
var neighbors = {
	Utils.Directions.UP: null,
	Utils.Directions.RIGHT: null,
	Utils.Directions.DOWN: null,
	Utils.Directions.LEFT: null
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_grid_position(coords:Vector2) -> void:
	self.grid_position = coords

func set_container(_container:StaticBody2D) -> bool:
	if !self.is_filled:
		#self.add_child(container)
		#container.position = Vector2(0,0)
		self.is_filled = true
		return true
	else:
		return false

func set_neighbor(direction: Utils.Directions, neighbor:StaticBody2D ) -> void:
	neighbors[direction] = neighbor

