extends CPUParticles2D



func start():
	global_position = owner.global_position + Vector2.UP * 32
	emitting = true
	

func stop():
	emitting = false
