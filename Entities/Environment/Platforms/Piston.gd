extends Node2D

var original_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	original_position = $FloorHeightMarker.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		$Line2D.points = [ to_local(original_position), to_local(owner.global_position)+Vector2.DOWN*16 ]
