extends StaticBody2D

@export var enter_left = false
@export var enter_right = false
@export var enter_up = false
@export var enter_down = false

var weigth:int = 100
var grid_position:Vector2 = Vector2(100,100)
var type: ContainerProperties.container_type = ContainerProperties.container_type.BLUE

var entrances = {
	Utils.Directions.LEFT: false,
	Utils.Directions.UP: false,
	Utils.Directions.RIGHT: false,
	Utils.Directions.DOWN: false,
}

# entrance_arrows:Dictionary = {Utils.Directions.LEFT: null}
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
	#$Exterior.show()
	
	var left_wall = $LeftCollision
	var right_wall = $RightCollision
	var top_wall = $TopCollision
	var bottom_wall = $BottomCollision
	var directions = []
	if (enter_left):
		directions.push_back(Utils.Directions.LEFT)
		# disable wall for now
		left_wall.disabled = true
	if (enter_right):
		directions.push_back(Utils.Directions.RIGHT)
		right_wall.disabled = true
	if (enter_up):
		directions.push_back(Utils.Directions.UP)
		top_wall.disabled = true
	if (enter_down):
		directions.push_back(Utils.Directions.DOWN)
		bottom_wall.disabled = true
	set_entrances(directions)

func set_grid_position(coordinate:Vector2) -> void:
	self.grid_position = coordinate
	$Label.text = "%s" % coordinate

func _on_container_interior_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		print("Showing outside container")
		$Exterior.show()

func _on_container_interior_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		print("Hidden outside container")
		$Exterior.hide()



