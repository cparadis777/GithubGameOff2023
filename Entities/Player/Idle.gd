#Idle.gd
extends PlayerState
var ducking : bool = false

signal started_idling

func _ready():
	super()
	await owner.ready
	if player.has_method("_on_started_idling"):
		started_idling.connect(player._on_started_idling)


func enter(_msg := {}) -> void:
	super()
	player.velocity = Vector2.ZERO
	started_idling.emit()


func physics_update(_delta: float) -> void:
	
#	if not player.is_on_floor():
#		state_machine.transition_to("Air")
#		return
	if Input.is_action_just_pressed("strong_punch"):
		state_machine.transition_to("StrongPunch")
		return
	elif Input.is_action_just_pressed("fast_punch"):
		state_machine.transition_to("FastPunch")
		return


	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.get_axis("move_left", "move_right") != 0:
		state_machine.transition_to("Run")

	# can also duck and jump down through some platforms.
	elif Input.is_action_just_pressed("move_down"):
		if player.has_method("detect_jump_through_platform"):
			var platform = player.detect_jump_through_platform()
			if platform != null:
				drop_down(platform)
			else:
				duck()

	elif player.detect_moving_platform() != null:
		player.move_and_slide()
	
	else:
		player.move_and_slide()
		if not player.is_on_floor():
			state_machine.transition_to("Air")
#	else: # make sure player sprite is snapped to pixels
#		player.global_position = floor(player.global_position)




func duck():
	print("player wants to duck, but that's not implemented yet.")
	
func drop_down(platform):
	# need to notify the platform to disable it's player layer mask temporarily
	if platform.has_method("allow_player_to_pass"):
		platform.allow_player_to_pass()
		state_machine.transition_to("Air", {do_drop = true})
		

	

