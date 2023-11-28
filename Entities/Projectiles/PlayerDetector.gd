extends Area2D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# chase the rigid body
	global_position = owner.global_position
