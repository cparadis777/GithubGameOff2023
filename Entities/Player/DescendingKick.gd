# DescendingKick.gd
extends PlayerState

var already_used_double_jump : bool = false

signal started
signal impacted
signal landed
var direction

@export var speed_multiplier : float = 2.5

func _ready():
	super()
	await owner.ready

	if player.has_method("_on_descending_kick_started"):
		started.connect(player._on_descending_kick_started)
	if player.has_method("_on_descending_kick_impacted"):
		impacted.connect(player._on_descending_kick_impacted)
	if player.has_method("_on_landed"):
		landed.connect(player._on_landed) # same function which Air connects to.


# If we get a message asking us kick, while in the Air, we descending kick
func enter(_msg := {}) -> void:
	player.velocity.y = 0.5 * player.JUMP_VELOCITY # going down
	
	
	direction = player.get_last_known_direction()
	if player.has_method("reset_rotation"):
		player.reset_rotation()
	
	player.velocity.x = speed_multiplier * player.speed * direction 
	started.emit() # so player can play animation


func physics_update(_delta: float) -> void:
	# No further Horizontal decisions.
	player.move_and_slide()
	
	# Landing.
	if player.is_on_floor():
		# this seems to fire early or too often.. why?
		state_machine.transition_to("Landing")
	
