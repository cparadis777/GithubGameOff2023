# Dash.gd
# when in air, if player presses fast_punch, they'll dash-punch

extends PlayerState

var already_used_double_jump : bool = false

signal started
signal impacted
signal landed
signal hit

var direction
@export var dash_duration : float = 0.33
@export var speed_multiplier : float = 2.75
var dash_speed : float
var timer
#var damage : float

func _ready():
	super()

	await owner.ready
	#damage = Globals.player_damage_defaults[name] * Globals.player_stats["damage_multiplier"]
	dash_speed = Globals.player_stats["speed"] * speed_multiplier

	if player.has_method("_on_dash_started"):
		started.connect(player._on_dash_started)
	if player.has_method("_on_dash_impacted"):
		impacted.connect(player._on_descending_kick_impacted)
	if player.has_method("_on_landed"):
		landed.connect(player._on_landed) # same function which Air connects to.


# If we get a message asking us kick, while in the Air, we descending kick
func enter(_msg := {}) -> void:
	player.velocity.y = 0 # stay flat
	timer = get_tree().create_timer(dash_duration) #starts automatically
	timer.timeout.connect(_on_timer_timeout)
	
	direction = player.get_last_known_direction()
#	if player.has_method("reset_rotation"):
#		player.reset_rotation()
	
	player.velocity.x = dash_speed * direction
	$DashHurtBox/DashCollisionShape.disabled = false
	
	started.emit() # so player can play animation

func exit():
	super()
	$DashHurtBox/DashCollisionShape.set_deferred("disabled", true)


func physics_update(_delta: float) -> void:
	# No further Horizontal decisions.
	player.move_and_slide()

	# Landing.
	if player.is_on_floor():
		state_machine.transition_to("Landing")
	

func _on_timer_timeout():
	player.velocity.x = 0.0
	state_machine.transition_to("Air", { "dashed" : true })
	


func _on_dash_hurt_box_body_entered(body):
	if state_machine.state == self:
		if body.is_in_group("Enemies") or body.is_in_group("Kickables"):
			var attackPacket = AttackPacket.new()
			attackPacket.damage = Globals.player_damage_defaults[name] * Globals.player_stats["damage_multiplier"]
			attackPacket.originator = self
			attackPacket.recipient = body
			attackPacket.impact_vector = player.velocity.normalized() + Vector2.UP * 0.5
			attackPacket.knockback = true
			attackPacket.knockback_speed = 150.0
			hit.connect(body._on_hit)
			hit.emit(attackPacket)
			hit.disconnect(body._on_hit)
			player.velocity = -player.velocity
			state_machine.transition_to("Air", {"do_jump" = true, "involuntary" = true})
			

