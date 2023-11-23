# Air.gd
extends PlayerState

var already_used_double_jump : bool = false
var already_used_dash : bool = false
var already_signalled_peak_amplitude : bool = false
var involuntary_jump : bool = false

signal jumped
signal peak_amplitude_reached


func _ready():
	super()

	await owner.ready

	if player.has_method("_on_jumped"):
		jumped.connect(player._on_jumped)
	if player.has_method("_on_peak_amplitude_reached"):
		peak_amplitude_reached.connect(player._on_peak_amplitude_reached)

# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	involuntary_jump = msg.has("involuntary")
	
	if msg.has("do_jump"): # up from the ground
		already_signalled_peak_amplitude = false
		player.velocity.y = -player.JUMP_VELOCITY
		if involuntary_jump:
			player.velocity.y *= 0.5
		jumped.emit()
	elif msg.has("do_drop"): # down from a platform
		player.velocity.y = 0.5 * player.JUMP_VELOCITY
	already_used_double_jump = msg.has("double_jumped")
	already_used_dash = msg.has("dashed") # one line version of: if msg.has "dashed": already_used_dash = true
	

# Note: Not the same as built in function physics_process!
func physics_update(delta: float) -> void:
	allow_player_to_change_direction_midair()
	apply_gravity(delta)
	end_jump_early_if_player_releases_button()
	check_for_double_jump_requests()
	check_for_attack_requests()
	player.move_and_slide()
	land_if_possible() # must be after move_and_slide
	

func check_for_double_jump_requests():
	if not already_used_double_jump and Input.is_action_just_pressed("jump"):
		already_used_double_jump = true
		state_machine.transition_to("DoubleJump")


func check_for_attack_requests():
	if Input.is_action_just_pressed("strong_punch"):
		state_machine.transition_to("DescendingKick")
	elif Input.is_action_just_pressed("fast_punch") and !already_used_dash:
		state_machine.transition_to("Dash")


func allow_player_to_change_direction_midair():
	# Horizontal movement.
	var input_direction_x = Input.get_axis("move_left", "move_right")
	player.velocity.x = player.speed * input_direction_x


	
func land_if_possible():
	if player.velocity.y >= 0 and player.is_on_floor():
		state_machine.transition_to("Landing")


func apply_gravity(delta):
#	# Vertical movement.
	if player.velocity.y < 0: # going up:
		player.velocity.y += player.gravity * delta
		if player.velocity.y > -0.1 and !already_signalled_peak_amplitude:
			peak_amplitude_reached.emit()
			already_signalled_peak_amplitude = true
	else: # going down (double accel):
		player.velocity.y += 2.0 * player.gravity * delta



func end_jump_early_if_player_releases_button():
	if !involuntary_jump:
		if player.velocity.y < 0 and !already_used_double_jump: # going up:
			if !Input.is_action_pressed("jump"):
				player.velocity.y = 0
			

