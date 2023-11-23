extends Node2D

@export var level_width: int = 384
@export var level_height: int = 192

@export_flags("Left", "Right", "Up", "Down") var exit_flags:int = 0
@export var enter_from:= Utils.Directions.LEFT

# Called when the node enters the scene tree for the first time.
func _ready():
	var directions = []
	if (exit_flags & Utils.DirectionFlags.LEFT):
		directions.push_back(Utils.Directions.LEFT)
	if (exit_flags & Utils.DirectionFlags.RIGHT):
		directions.push_back(Utils.Directions.RIGHT)
	if (exit_flags & Utils.DirectionFlags.UP):
		directions.push_back(Utils.Directions.UP)
	if (exit_flags & Utils.DirectionFlags.DOWN):
		directions.push_back(Utils.Directions.DOWN)
	if has_node("BaseContainer") and $BaseContainer.has_method("set_entrances"):
		$BaseContainer.set_entrances(directions)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# enable or disable the collider walls
func set_walls_disabled(state:bool, side = null) -> void:
	match(side):
		Utils.Directions.LEFT:
			$BaseContainer/LeftCollision.disabled = state
		Utils.Directions.RIGHT:
			$BaseContainer/RightCollision.disabled = state
		Utils.Directions.UP:
			$BaseContainer/TopCollision.disabled = state
		Utils.Directions.DOWN:
			$BaseContainer/BottomCollision.disabled = state
		_:
			$BaseContainer/LeftCollision.disabled = state
			$BaseContainer/RightCollision.disabled = state
			$BaseContainer/TopCollision.disabled = state
			$BaseContainer/BottomCollision.disabled = state
			

func _on_next_level_door_level_exited(side):
	set_walls_disabled(true, side)
