extends Node2D

var original_position :Vector2 


# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	await get_tree().create_timer(0.7).timeout
	original_position = owner.get_node("PositionMarkers").get_child(0).global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if original_position != null and visible:
		for cable in get_children():
			cable.points = [ Vector2.ZERO, original_position - owner.platform.global_position+(Vector2.DOWN*16) ]

