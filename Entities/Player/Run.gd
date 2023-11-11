# Run.gd
extends PlayerState

signal running_started

func _ready():
	super()
	await owner.ready
	if player.has_method("_on_started_running"):
		running_started.connect(player._on_started_running)


func enter(_msg := {}) -> void:
	running_started.emit()

func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.

	var input_direction_x: float = Input.get_axis("move_left", "move_right")


	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
		return
	elif is_equal_approx(input_direction_x, 0.0):
		state_machine.transition_to("Idle")
		return
	elif Input.is_action_just_pressed("strong_punch"):
		state_machine.transition_to("StrongPunch")
		return
	elif Input.is_action_just_pressed("fast_punch"):
		state_machine.transition_to("FastPunch")
		return
	elif not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	else:
		player.velocity.x = player.speed * input_direction_x
		player.velocity.y += player.gravity * delta
		var collision_detected = player.move_and_slide()
		if collision_detected:
			var collision : KinematicCollision2D = player.get_last_slide_collision()
			attempt_to_push(collision)
		player.get_platform_velocity()



func attempt_to_push(collision : KinematicCollision2D):
	var body = collision.get_collider()
	if body.is_in_group("Pushables"):
		var magnitude = 4.5
		var impactVector = magnitude * (player.global_position.direction_to(body.global_position) + Vector2.UP)
		if body.has_method("push"):
			body.push(impactVector)
	
	
