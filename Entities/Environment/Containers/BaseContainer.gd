extends StaticBody2D

@export var enter_left = false
@export var enter_right = false
@export var enter_up = false
@export var enter_down = false

@export var doors_open = false
@export var open_doors_with_switch = false

var weigth:int = 100
var grid_position:Vector2 = Vector2(100,100)
var type: ContainerProperties.container_type = ContainerProperties.container_type.BLUE

var has_entrance = {
	Utils.Directions.LEFT: false,
	Utils.Directions.UP: false,
	Utils.Directions.RIGHT: false,
	Utils.Directions.DOWN: false,
}

@onready var walls = {
	Utils.Directions.LEFT: $LeftCollision,
	Utils.Directions.UP: $TopCollision,
	Utils.Directions.RIGHT: $RightCollision,
	Utils.Directions.DOWN: $BottomCollision,
}

@onready var doors = {
	Utils.Directions.LEFT: $Doors/LEFT,
	Utils.Directions.UP: $Doors/UP,
	Utils.Directions.RIGHT: $Doors/RIGHT,
	Utils.Directions.DOWN: $Doors/DOWN,
}

# entrance_arrows:Dictionary = {Utils.Directions.LEFT: null}
# Called when the node enters the scene tree for the first time.

func _ready():
	$Exterior.visible = true;
	
	if enter_left:
		has_entrance[Utils.Directions.LEFT] = true
		# left_wall.disabled = true
		$Openings/Left.visible = true;
	if enter_right:
		has_entrance[Utils.Directions.RIGHT] = true
		# right_wall.disabled = true
		$Openings/Right.visible = true;
	if enter_up:
		has_entrance[Utils.Directions.UP] = true
		# top_wall.disabled = true
		$Openings/Top.visible = true;
	if enter_down:
		has_entrance[Utils.Directions.DOWN] = true
		# bottom_wall.disabled = true
		$Openings/Bottom.visible = true;
		
	if doors_open:
		open_all_doors()
		
func open_door(side:Utils.Directions):
	# change the sprite?
	# door_sprites[side]
	if has_entrance[side]:
		walls[side].disabled = true
		if has_node("Doors"):
				doors[side].locked = false
				pass

func open_all_doors():
	# when room is completed, we can open all available doors
	# we'll need some way to tell the adjacent containers to open their entrances
	# maybe fire an event for the grid manager to catch and use coordinates to unlock
	# adjacent doors
	print("container beaten")
	for side in has_entrance:
		if has_entrance[side]:
			walls[side].disabled = true
			if has_node("Doors"):
				doors[side].locked = false
				pass
			

func _on_switch_toggled(pressed):
	if open_doors_with_switch:
		open_all_doors()
	
func _on_container_interior_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		print("Showing outside container")
		$Exterior.show()

func _on_container_interior_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		print("Hidden outside container")
		$Exterior.hide()



