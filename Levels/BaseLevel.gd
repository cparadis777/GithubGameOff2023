extends Node2D

@export var level_width: int = 384
@export var level_height: int = 192

enum dir_flags {LEFT = 1, RIGHT = 2, UP = 4, DOWN = 8}

@export_flags("Left", "Right", "Up", "Down") var exit_flags:int = 0
@export var enter_from: dir_flags

# Called when the node enters the scene tree for the first time.
func _ready():
	var directions = []
	if (exit_flags & dir_flags.LEFT):
		directions.push_back(Utils.Directions.LEFT)
	if (exit_flags & dir_flags.RIGHT):
		directions.push_back(Utils.Directions.RIGHT)
	if (exit_flags & dir_flags.UP):
		directions.push_back(Utils.Directions.UP)
	if (exit_flags & dir_flags.DOWN):
		directions.push_back(Utils.Directions.DOWN)
	$BaseContainer.set_entrances(directions)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# enable or disable the collider walls
func set_walls_disabled(state:bool) -> void:
	$BaseContainer/BottomCollision.disabled = state
	$BaseContainer/TopCollision.disabled = state
	$BaseContainer/LeftCollision.disabled = state
	$BaseContainer/RightCollision.disabled = state
	

func _on_next_level_door_level_exited():
	set_walls_disabled(true)
