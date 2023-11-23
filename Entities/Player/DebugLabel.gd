extends Label

enum Systems { State, PlayerHealth }

@export var system_to_monitor: Systems = Systems.State


func _ready():
	await owner.ready
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match system_to_monitor:
		Systems.State:
			text = owner.state_machine.state.name
		Systems.PlayerHealth:
			text = str(owner.health)

			
