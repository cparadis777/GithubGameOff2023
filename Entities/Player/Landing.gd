# Landing.gd - a short player state between airborne states and ground states

extends PlayerState

signal landed

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await owner.ready
	if player.has_method("_on_landed"):
		landed.connect(player._on_landed)

func enter(_msg := {} ) -> void:
	super()
#	if abs(Input.get_axis("move_left", "move_right")) > 0:
#		state_machine.transition_to("Run")
	landed.emit() # player will play an animation
	
	
func exit():
	super()

func physics_update(_delta):
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump")
	elif abs(Input.get_axis("move_left", "move_right")) > 0:
		state_machine.transition_to("Run")


func _on_player_animation_finished(anim_name):
	if anim_name == "landed":
		if abs(player.velocity.x) > 0.05: 
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
