extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready():
	super()


func enter(_msg := {}) -> void:
	$CPUParticles2D.emitting = true
	
func exit():
	pass

