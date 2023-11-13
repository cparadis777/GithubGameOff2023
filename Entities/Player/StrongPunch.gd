extends PlayerState

signal started

enum SubStates { INITIALIZING, CHARGING, EXECUTING, FINISHED }
var SubState = SubStates.INITIALIZING

var time_of_entry : int # msec
var last_polling_time : int = time_of_entry
var interval_between_polls : int = 200 #msec

@export var moving : bool = false
@export var cancel_frames_active: bool = false

@export var charge_vfx : Node 
# Called when the node enters the scene tree for the first time.
func _ready():
	charge_vfx.hide()
	super()
	await owner.ready
	started.connect(player._on_strong_punch_started)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	
	if SubState == SubStates.CHARGING:
		var current_time = Time.get_ticks_msec()
		if current_time > last_polling_time + interval_between_polls:
			last_polling_time = current_time
			amplify_vfx(delta)
		if !Input.is_action_pressed("strong_punch") and !player.animation_player.is_playing():
			execute_punch()
	elif SubState == SubStates.EXECUTING and moving:
		move_forward(delta)

	if cancel_frames_active:
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", {"do_jump" = true})
		elif Input.is_action_just_pressed("strong_punch"):
			state_machine.transition_to("StrongPunch")
		elif Input.is_action_just_pressed("fast_punch"):
			state_machine.transition_to("FastPunch")

func reset_vfx():
	charge_vfx.lifetime = 0.5
	charge_vfx.amount = 48
	charge_vfx.scale_amount_min = 1.0
	charge_vfx.scale_amount_max = 1.0
	charge_vfx.initial_velocity_min = 40.0
	charge_vfx.initial_velocity_max = 80.0
	
	
func amplify_vfx(delta):
	charge_vfx.emitting = false
	charge_vfx.lifetime = min(charge_vfx.lifetime + 2.0 * delta, 5)
	charge_vfx.scale_amount_min = min(charge_vfx.scale_amount_min + delta * 20, 5)
	charge_vfx.scale_amount_max = charge_vfx.scale_amount_min * 1.25
	var velocity_increase = 40.0
	charge_vfx.initial_velocity_min = min(charge_vfx.initial_velocity_min + delta * velocity_increase, 400)
	charge_vfx.initial_velocity_max = charge_vfx.initial_velocity_min * 1.25
	charge_vfx.emitting = true
		
	#charge_vfx.amount += int(25.0 * delta)
		
	
func move_forward(_delta):
	player.velocity.x = player.SPEED * 0.75 * player.get_last_known_direction()
	player.move_and_slide()

# moved to property track in animation player
#func start_moving():
#	moving = true
#
#func stop_moving():
#	moving = false

func execute_punch():
	charge_vfx.lifetime = 0.5
	charge_vfx.emitting = false
	SubState = SubStates.EXECUTING
	player.animation_player.play()
	

func hold_for_key_release():
	player.animation_player.pause()
	
	

func enter(_msg := {}) -> void:
	time_of_entry = Time.get_ticks_msec()
	started.emit() # to the player
	SubState = SubStates.CHARGING
	reset_vfx()
	charge_vfx.emitting = true
	charge_vfx.show()
	cancel_frames_active = true
	
#	await get_tree().create_timer(0.8).timeout
#
#	SubState = SubStates.FINISHED

#	if abs(Input.get_axis("move_left", "move_right")) > 0.05:
#		state_machine.transition_to("Run")
#	else:
#		state_machine.transition_to("Idle")
	
	
func exit():
	reset_vfx
	charge_vfx.hide()
	moving = false
	SubState = SubStates.INITIALIZING
	var col_shape = player.find_child("StrongCollisionShape")
	if col_shape != null:
		col_shape.disabled = true

func _on_player_animation_finished(anim_name):
	if anim_name == "strong_punch":
		if abs(Input.get_axis("move_left", "move_right")) > 0.05:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
