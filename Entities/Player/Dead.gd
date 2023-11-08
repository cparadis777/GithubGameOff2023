extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide()
	

func enter(_msg := {} ):
	$Label.show()

