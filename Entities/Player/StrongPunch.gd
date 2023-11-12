extends PlayerState

signal started

enum SubStates { WAITING, PLAYING, FINISHED }
var SubState = SubStates.WAITING

var time_of_entry : int # msec
var moving : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await owner.ready
	started.connect(player._on_strong_punch_started)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	if moving:
		move_forward(delta)
	
func move_forward(_delta):
	player.velocity.x = player.SPEED * 0.75 * player.get_last_known_direction()
	player.move_and_slide()

func start_moving():
	moving = true

func stop_moving():
	moving = false
	


func enter(_msg := {}) -> void:
	time_of_entry = Time.get_ticks_msec()
	started.emit() # to the player
	SubState = SubStates.PLAYING

	await get_tree().create_timer(0.8).timeout

	SubState = SubStates.FINISHED

#	if abs(Input.get_axis("move_left", "move_right")) > 0.05:
#		state_machine.transition_to("Run")
#	else:
#		state_machine.transition_to("Idle")
	
	
func exit():
	pass

func _on_player_animation_finished(anim_name):
	if anim_name == "strong_punch":
		if abs(Input.get_axis("move_left", "move_right")) > 0.05:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
