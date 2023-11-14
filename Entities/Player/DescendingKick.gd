# DescendingKick.gd
extends PlayerState

var already_used_double_jump : bool = false

signal started
signal landed
var direction
var damage # obtained from player

@export var speed_multiplier : float = 2.5

func _ready():
	super()
	await owner.ready
	damage = player.damage_defaults[name]
	if player.has_method("_on_descending_kick_started"):
		started.connect(player._on_descending_kick_started)
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

	$UnstuckTimer.start()

func exit():
	$UnstuckTimer.stop()

func physics_update(_delta: float) -> void:
	# No further Horizontal decisions.
	player.move_and_slide()
	
	# Landing.
	if player.is_on_floor():
		if player.detect_npcs_underfoot().size() > 0:
			player.velocity.x = -player.velocity.x
			state_machine.transition_to("Air", {"do_jump" = true, "involuntary" = true})
		else:
			state_machine.transition_to("Landing")
		
	


func _on_unstuck_timer_timeout():
	if state_machine.state == self:
		# why are you still in this state after 3 seconds?
		# player is probably trapped in a corner.
		player.velocity = -player.velocity
		state_machine.transition_to("Air", {"do_jump" = true})
