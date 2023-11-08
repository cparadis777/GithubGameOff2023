extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await(owner.ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta):
	pass

func enter(_msg := {}) -> void:
	player.strong_punch()

func exit():
	pass
	
