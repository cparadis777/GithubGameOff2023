extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await(owner.ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta):
	pass

func enter(_msg := {}) -> void:
	player.strong_punch()

func exit():
	pass

func _on_player_animation_finished(anim_name):
	if anim_name == "strong_punch":
		if abs(Input.get_axis("move_left", "move_right")) > 0.05:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
