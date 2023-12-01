extends RigidBody2D


func _ready():
	#hide()
	freeze = true
	


func activate(location, impactVector):
	global_position = location
	self.scale = Vector2.ONE * randf_range(0.33, 1.2)
	#show()
	freeze = false
	call_deferred("apply_central_force", impactVector)
	$CrashNoise.play()
	
func _on_hit(attackPacket : AttackPacket):
	var magnitude = 6.0
	apply_central_impulse(attackPacket.impact_vector * attackPacket.knockback_speed * magnitude)
	apply_torque_impulse(randf_range(-3,3))
	$DebrisParticles.global_position = global_position
	$DebrisParticles.emitting = true
	make_noise()
	await get_tree().create_timer(1.2).timeout
	call_deferred("queue_free")

func make_noise():
	var newNoise = $CrashNoise.duplicate()
	get_tree().get_root().add_child(newNoise)
	newNoise.finished.connect(newNoise.queue_free)
	newNoise.play()
