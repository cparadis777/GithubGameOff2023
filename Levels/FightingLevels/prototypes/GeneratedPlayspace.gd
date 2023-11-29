extends Node2D


@onready var container_grid = $ContainerGrid

func _ready():
	self.create_playspace(StageManager.playspace_parameters)
	
	#$CanvasModulate.show() # is it better without lighting?
	AudioManager.play_track("FightingTheme")


"""
Form of playspace_parameters:
{
	shape: Vector2(n,m),
	containers: {
		Vector2(x,y): {
			type: ContainerProperties.container_type, exits: {
					Utils.Directions: bool
			}
		}	
	}
}

"""

func create_playspace(playspace_parameters:Dictionary = {}) -> void:
	if playspace_parameters.is_empty():
		return

	#var playspace_size:Vector2 = playspace_parameters["shape"]
	#self.container_grid.generate_slots(playspace_size)
	var containers:Dictionary = ContainerCatalog.generate_playspace(playspace_parameters["containers"])
	
	for coordinate in containers:

		container_grid.set_container(containers[coordinate], coordinate)
	
