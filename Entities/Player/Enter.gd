# Enter.gd
extends PlayerState

var dir := Utils.Directions.RIGHT
var direction_x: float = 0.0
var direction_y: float = 0.0

func enter(_msg := {}) -> void:
	print_debug("success!")
	if player.has_method("reset_rotation"):
		player.reset_rotation()
	if (_msg.dir is Utils.Directions):
		match (_msg.dir):
			Utils.Directions.RIGHT:
				direction_x = 1.0
			Utils.Directions.LEFT:
				direction_x = -1.0
			Utils.Directions.UP:
				direction_y = 1.0
			Utils.Directions.DOWN:
				direction_y = -1.0
		

func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
			
	player.velocity.x = player.speed * direction_x
	player.velocity.y += player.speed * direction_y
	var collision_detected = player.move_and_slide()
	if collision_detected:
		var collision : KinematicCollision2D = player.get_last_slide_collision()
		attempt_to_push(collision)

	player.get_platform_velocity()

"""
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif is_equal_approx(input_direction_x, 0.0):
		state_machine.transition_to("Idle")

	elif Input.is_action_just_pressed("strong_punch"):
		state_machine.transition_to("StrongPunch")
			
	elif Input.is_action_just_pressed("fast_punch"):
		state_machine.transition_to("FastPunch")
"""			


func attempt_to_push(collision : KinematicCollision2D):
	var body = collision.get_collider()
	if body.is_in_group("Pushables"):
		var magnitude = 3.5
		var impactVector = magnitude * (player.global_position.direction_to(body.global_position) + Vector2.UP)
		if body.has_method("push"):
			body.push(impactVector)
	

	
