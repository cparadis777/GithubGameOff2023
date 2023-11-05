# Air.gd
extends PlayerState

var already_used_double_jump : bool = false
var already_used_dash : bool = false
var already_signalled_peak_amplitude : bool = false

signal jumped
signal double_jumped
signal peak_amplitude_reached
signal landed

func _ready():
	super()

	await(owner.ready)
	if player.has_method("_on_double_jumped"):
		double_jumped.connect(player._on_double_jumped)
	if player.has_method("_on_landed"):
		landed.connect(player._on_landed)
	if player.has_method("_on_jumped"):
		jumped.connect(player._on_jumped)
	if player.has_method("_on_peak_amplitude_reached"):
		peak_amplitude_reached.connect(player._on_peak_amplitude_reached)

# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		already_signalled_peak_amplitude = false
		player.velocity.y = -player.JUMP_VELOCITY
		jumped.emit()
	elif msg.has("do_drop"):
		player.velocity.y = 0.5 * player.JUMP_VELOCITY
	already_used_double_jump = false
	
	already_used_dash = msg.has("dashed")

	
func physics_update(delta: float) -> void:
	# Horizontal movement.

	var input_direction_x = Input.get_axis("move_left", "move_right")
	
	player.velocity.x = player.speed * input_direction_x
	

	apply_gravity(delta)
	if player.velocity.y < 0.1 and not already_signalled_peak_amplitude:
		peak_amplitude_reached.emit()
		already_signalled_peak_amplitude = true
	end_jump_early_if_player_releases_button()
	
	if Input.is_action_just_pressed("jump") and !already_used_double_jump:
		player.velocity.y = -player.JUMP_VELOCITY
		double_jumped.emit()
		already_used_double_jump = true
	elif Input.is_action_just_pressed("kick"):
		state_machine.transition_to("DescendingKick")
	elif Input.is_action_just_pressed("punch") and !already_used_dash:
		state_machine.transition_to("Dash")

	player.move_and_slide()

	# Landing.
	if player.is_on_floor():
		landed.emit()
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")

func apply_gravity(delta):
	# Vertical movement.
	if player.velocity.y < 0: # going up:
		player.velocity.y += player.gravity * delta
	else: # going down:
		player.velocity.y += 2.0 * player.gravity * delta

func 	end_jump_early_if_player_releases_button():
	if player.velocity.y < 0: # going up:
		if !Input.is_action_pressed("jump"):
			player.velocity.y = 0
			
