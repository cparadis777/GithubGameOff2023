# Air.gd
extends PlayerState

var already_used_double_jump : bool = false

signal double_jumped

# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		player.velocity.y = -player.JUMP_VELOCITY
	already_used_double_jump = false
	if !double_jumped.is_connected(player._on_double_jumped):
		double_jumped.connect(player._on_double_jumped)

func physics_update(delta: float) -> void:
	# Horizontal movement.
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	player.velocity.x = player.speed * input_direction_x
	# Vertical movement.
	player.velocity.y += player.gravity * delta
	if Input.is_action_just_pressed("jump") and !already_used_double_jump:
		player.velocity.y = -player.JUMP_VELOCITY
		double_jumped.emit()
		already_used_double_jump = true
	player.move_and_slide()

	# Landing.
	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
