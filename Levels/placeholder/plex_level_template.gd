extends Node2D

@export var num_objects : int = 6

# note: order of exit flags must match the order in Utils.DirectionFlags
@export_flags("LEFT", "RIGHT", "UP", "DOWN") var container_exit_flags:int = 15
@onready var exits_container_node = $Exits

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_random_shit()

	remove_unneeded_doors()
	
func remove_unneeded_doors():
	if container_exit_flags < 15:
		for exit in exits_container_node.get_children():

			# bitwise comparison math based on the name of the exit
			# exits must be named LEFT, RIGHT, UP, or DOWN for this to work
			if Utils.DirectionFlags[exit.name] & container_exit_flags:
				exit.show()
			else:
				exit.queue_free()

func spawn_random_shit():
	$SpawningLogic.spawn_random_shit(num_objects)
