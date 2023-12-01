# DescendingKick.gd
extends PlayerState

var already_used_double_jump : bool = false

signal started
signal landed
signal hit
var direction
#var damage # obtained from player

@export var speed_multiplier : float = 2.5

func _ready():
	super()
	await owner.ready
	#damage = Globals.player_damage_defaults[name]
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
	
	player.velocity.x = speed_multiplier * Globals.player_stats["speed"] * direction 
	started.emit() # so player can play animation

	$UnstuckTimer.start()
	$DescendingKickTimer.start()

func exit():
	$UnstuckTimer.stop()

func physics_update(_delta: float) -> void:
	# No further Horizontal decisions.
	player.move_and_slide()
	
	# Landing.
	if player.is_on_floor():
		$DescendingKickTimer.stop()
		$UnstuckTimer.stop()
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


func _on_hurt_box_body_entered(body):
	if body.is_in_group("Enemies") or body.is_in_group("Kickables"):
		if state_machine.state.name == "DescendingKick":
			var attackPacket = AttackPacket.new()
			attackPacket.originator = player
			attackPacket.recipient = body
			attackPacket.damage =  Globals.player_damage_defaults[name] * Globals.player_stats["damage_multiplier"]
			attackPacket.impact_vector = Vector2(sign(player.velocity.x), -1)
			attackPacket.knockback = true
			attackPacket.knockback_speed = 150.0
			hit.connect(body._on_hit)
			hit.emit(attackPacket)
			hit.disconnect(body._on_hit)	
#			player.inflict_harm(body, Globals.player_damage_defaults["DescendingKick"], true, false)
#			player.velocity.x = -player.velocity.x
#			player.velocity.y = - 1.25 * player.JUMP_VELOCITY
			#state_machine.transition_to("Air", {"do_jump" = true, "involuntary" = true})
			state_machine.transition_to("Air")



func _on_descending_kick_timer_timeout():
	if state_machine.state == self:
		state_machine.transition_to("Air")
		# You might need to pass an argument that says already kicked or something.. to prevent chain maneuver abuse.
