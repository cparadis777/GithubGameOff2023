extends StaticBody2D

# note: order of exit flags must match the order in Utils.DirectionFlags
@export_flags("LEFT", "RIGHT", "UP", "DOWN") var container_exit_flags:int = 15
@onready var exits_container_node

@export var doors_unlocked = true
@export var open_doors_with_switch = false
@export var show_exterior_on_start = true

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
	Utils.Directions.LEFT: $Exits/LEFT,
	Utils.Directions.UP: $Exits/UP,
	Utils.Directions.RIGHT: $Exits/RIGHT,
	Utils.Directions.DOWN: $Exits/DOWN,
}

# entrance_arrows:Dictionary = {Utils.Directions.LEFT: null}
# Called when the node enters the scene tree for the first time.

func _ready():
	if (show_exterior_on_start):
		$Exterior.visible = true
	else:
		$Exterior.visible = false
	
	if (has_node("Exits")):
		exits_container_node = $Exits
	else:
		print_debug("using deprecated BaseContainer. Use res://Entities/Environment/Containers/LargeContainer.tscn instead")
	
	remove_unneeded_doors()
	
	if doors_unlocked:
		open_all_doors()

func remove_unneeded_doors():
	if container_exit_flags < 15:
		#print("found a container to check.")

		for exit in exits_container_node.get_children():
			# bitwise comparison math based on the name of the exit
			# exits must be named LEFT, RIGHT, UP, or DOWN for this to work
			if Utils.DirectionFlags[exit.name] & container_exit_flags:
				has_entrance[Utils.flag_to_direction(Utils.DirectionFlags[exit.name])] = true;
				exit.visible = true
			else:
				exit.queue_free()
		
func open_door(side:Utils.Directions):
	# change the sprite?
	# door_sprites[side]
	if has_entrance[side]:
		doors[side].locked = false

func open_all_doors():
	# when room is completed, we can open all available doors
	# we'll need some way to tell the adjacent containers to open their entrances
	# maybe fire an event for the grid manager to catch and use coordinates to unlock
	# adjacent doors
	print("container beaten")
	for side in has_entrance:
		doors[side].locked = false
			

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



