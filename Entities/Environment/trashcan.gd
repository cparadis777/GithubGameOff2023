extends RigidBody2D

var kicked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_hit(_damage, impactVector, _damageType, _knockback):
	freeze = false
	var intensity = 15.0
	$HurtNoises.play()
	apply_central_impulse(impactVector * intensity + Vector2.UP * 10.0 * intensity)
