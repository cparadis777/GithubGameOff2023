extends Node2D

@export var Container_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var positions:Array[Vector2] = [Vector2(0,0), Vector2(2,1), Vector2(4,1)]
	for grid_position in positions:
		var container:StaticBody2D = Container_scene.instantiate()
		$DropPoints.add_container(container, grid_position)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
