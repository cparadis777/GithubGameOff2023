#Idle.gd
extends PlayerState
var ducking : bool = false

func enter(_msg := {}) -> void:
	player.velocity = Vector2.ZERO


func physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		state_machine.transition_to("Run")

	# can also duck and jump down through some platforms.
	if Input.is_action_just_pressed("move_down"):
		if player.has_method("detect_jump_through_platform"):
			var platform = player.detect_jump_through_platform()
			if platform != null:
				drop_down(platform)
			else:
				duck()
		else:
			printerr("coupling problem: Air state requested method detect_jump_through_platform from player, but it did not exist.")
	
	player.move_and_slide()
			
func duck():
	print("player wants to duck, but that's not implemented yet.")
	
func drop_down(platform):
	# need to notify the platform to disable it's player layer mask temporarily
	if platform.has_method("allow_player_to_pass"):
		platform.allow_player_to_pass()
		state_machine.transition_to("Air", {do_drop = true})
		
	
	

