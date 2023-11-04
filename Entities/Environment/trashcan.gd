extends RigidBody2D

var kicked = false

@export var soda_can : PackedScene = preload("res://Entities/Environment/Kickables/soda_can.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_soda_cans(impactVector):
	for i in range(randi_range(3,7)):
		var new_soda_can : RigidBody2D = soda_can.instantiate()
		var distance = 16.0
		var jitter = 0.3 # radians
		var bounce_vector = impactVector.normalized().rotated(randf_range(-jitter, jitter))
		call_deferred("add_sibling", new_soda_can)
		new_soda_can.global_position = self.global_position - bounce_vector * distance
		await new_soda_can.ready
		new_soda_can.apply_central_impulse(bounce_vector)


func _on_hit(_damage, impactVector, _damageType, _knockback):
	if !kicked:
		spawn_soda_cans(impactVector)
		
	freeze = false
	var intensity = 15.0
	$HurtNoises.play()
	apply_central_impulse(impactVector * intensity + Vector2.UP * 10.0 * intensity)
	kicked = true
	
	
