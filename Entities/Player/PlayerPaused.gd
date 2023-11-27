extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func enter(_msg = {}):
	pass
	
func resume():
	state_machine.transition_to("Idle")
	
