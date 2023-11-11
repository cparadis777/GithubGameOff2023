extends Node2D

var original_position :Vector2 


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	original_position = owner.get_node("PositionMarkers").get_child(0).global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	for cable in get_children():
		cable.points = [ owner.position, original_position ]

