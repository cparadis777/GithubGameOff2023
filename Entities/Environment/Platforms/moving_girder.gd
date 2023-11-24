extends "res://Entities/Environment/Platforms/moving_platform.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func _physics_process(delta):
	super(delta) # is this needed in _process()?
#	for cable in $Cables.get_children():
#		if locations.size() > 0:
#			cable.points = [global_position, locations[0]] # local coordinates
#
