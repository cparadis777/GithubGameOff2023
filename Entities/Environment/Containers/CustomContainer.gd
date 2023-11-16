extends "res://Entities/Environment/Containers/BaseContainer.gd"

@export var enter_left = false
@export var enter_right = false
@export var enter_up = false
@export var enter_down = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Exterior.show()
	
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
	#set_entrances(directions)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
