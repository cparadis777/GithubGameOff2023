extends PlayerState

signal started

enum SubStates { INITIALIZING, CHARGING, EXECUTING, FINISHED }
var SubState = SubStates.INITIALIZING

var time_of_entry : int # msec
var punch_direction : int
var last_polling_time : int = time_of_entry
var interval_between_polls : int = 200 #msec

var final_charge_duration : int
var damage

var this_punch_already_landed : bool = false

@export var stepping_back : bool = false
@export var moving : bool = false :
	set(value):
		moving = value
		_on_moving_forward()
	get:
		return moving
@export var cancel_frames_active: bool = false

@export var charge_vfx : Node 

signal hit


func _ready():
	charge_vfx.hide()
	super()
	await owner.ready
	damage = Globals.player_damage_defaults[name]
	started.connect(player._on_strong_punch_started)
	$HurtBox/StrongCollisionShape.disabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	if SubState == SubStates.CHARGING and stepping_back:
		move_backward(delta)
	if SubState == SubStates.CHARGING:
		var current_time = Time.get_ticks_msec()
		if current_time > last_polling_time + interval_between_polls:
			last_polling_time = current_time
			amplify_vfx(delta)
		if !Input.is_action_pressed("strong_punch") and !player.animation_player.is_playing():
			execute_punch()
	elif SubState == SubStates.EXECUTING and moving:
		move_forward(delta)
	# this doesn't seem to work, likely because the position of the sprite is set in animation
#	apply_gravity(delta)
#	sync_motion_to_platforms(delta)
	allow_early_exit()
	
func allow_early_exit():
	# some frames are marked as cancel frames.
	# if player presses an action during those frames,
	# they should be permitted to start a new action
	# see: Masahiro Sakurai https://www.youtube.com/watch?v=LewXWM7HDd8
	if cancel_frames_active:
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", {"do_jump" = true})
		# it felt weird starting a new strong punch during a strong punch charge,
		# so we'll restrict it to after the punch is executed.
		elif SubState in [SubStates.EXECUTING, SubStates.FINISHED]:
	
			if Input.is_action_just_pressed("strong_punch"):
				if player.is_on_floor():
					state_machine.transition_to("StrongPunch")
				else:
					state_machine.transition_to("DescendingKick")
			elif Input.is_action_just_pressed("fast_punch"):
				if player.is_on_floor():
					state_machine.transition_to("FastPunch")
				else:
					state_machine.transition_to("Dash")

	
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
		
func move_backward(_delta):
	player.velocity.x = Globals.player_stats["speed"] * -2.25 * punch_direction
	player.move_and_slide()
		
func move_forward(_delta):
	player.velocity.x = Globals.player_stats["speed"] * 3.25 * punch_direction
	player.move_and_slide()

# moved to property track in animation player
#func start_moving():
#	moving = true
#
#func stop_moving():
#	moving = false

func execute_punch():
	final_charge_duration = Time.get_ticks_msec() - time_of_entry
	charge_vfx.lifetime = 0.5
	charge_vfx.emitting = false
	SubState = SubStates.EXECUTING
	player.animation_player.play()
	

func hold_for_key_release():
	player.animation_player.pause()
	
func _on_moving_forward():
	# called from setget of moving property, which is set by animation player
	pass

func enter(_msg := {}) -> void:
	punch_direction = player.get_last_known_direction()
	this_punch_already_landed = false
	final_charge_duration = 0
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
	# chasing bug 139 https://github.com/cparadis777/GithubGameOff2023/issues/139
	#player.animation_player.call_deferred("stop")
	$ChargeAudio.stop()
	reset_vfx()
	charge_vfx.hide()
	moving = false
	SubState = SubStates.INITIALIZING
	var col_shape = player.find_child("StrongCollisionShape")
	if col_shape != null:
		col_shape.set_deferred("disabled", true)


func _on_player_animation_finished(anim_name):
	if anim_name == "strong_punch":
		if abs(Input.get_axis("move_left", "move_right")) > 0.05:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")


func _on_hurt_box_body_entered(body):
	if state_machine.state == self:
		if body.is_in_group("Enemies") or body.is_in_group("Kickables"):
			var charge_multiplier = clampf(float(final_charge_duration) / 500.0, 1.0, 3.5)
			var actual_damage = floor(Globals.player_damage_defaults[name] * Globals.player_stats["damage_multiplier"] * charge_multiplier)
			if not this_punch_already_landed:
				$ImpactAudio.play()
				this_punch_already_landed = true
			
			var attackPacket = AttackPacket.new()
			attackPacket.originator = player
			attackPacket.recipient = body
			attackPacket.damage = actual_damage
			attackPacket.knockback = true
			attackPacket.impact_vector = Vector2(player.get_last_known_direction(), -1)
			attackPacket.knockback_speed = 2.0
			hit.connect(body._on_hit)
			hit.emit(attackPacket)
			hit.disconnect(body._on_hit)
			
			#player.inflict_harm(body, actual_damage, knockback_magnitude, uppercut)

