extends Label

enum Systems { PlayerState, PlayerHealth }

@export var system_to_monitor: Systems = Systems.PlayerState




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match system_to_monitor:
		Systems.PlayerState:
			text = owner.state_machine.state.name
		Systems.PlayerHealth:
			text = str(owner.health)

			
