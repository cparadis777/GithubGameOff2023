extends Node2D


@onready var container_grid = $ContainerGrid

func _ready():
	self.create_playspace(StageManager.playspace_parameters)
"""
	create_playspace({
		"shape": Vector2(2,2),
		"containers": {
			Vector2(0,0): {
				"type": ContainerProperties.container_type.BLUE,
				"exits": {
					Utils.Directions.UP: false,
					Utils.Directions.RIGHT: false,
					Utils.Directions.DOWN: false,
					Utils.Directions.LEFT: false
				}
			},
			Vector2(0,1): {
				"type": ContainerProperties.container_type.BLUE,
				"exits": {
					Utils.Directions.UP: false,
					Utils.Directions.RIGHT: false,
					Utils.Directions.DOWN: false,
					Utils.Directions.LEFT: false
			}
		}
	}
}
)
"""


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

	var playspace_size:Vector2 = playspace_parameters["shape"]
	self.container_grid.generate_slots(playspace_size)
	var containers:Dictionary = ContainerCatalog.generate_playspace(playspace_parameters["containers"])
	
	for coordinate in containers:
		var container_scene = load(containers[coordinate].scene_path)
		var container = container_scene.instantiate()
		container_grid.set_container(container, coordinate)
	
