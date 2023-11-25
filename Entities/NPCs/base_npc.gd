extends CharacterBody2D


@export var SPEED : float = 40.0
@export var JUMP_VELOCITY : float = -150.0
@export var base_damage : float = 10

@export var health_max = 100.0
var health = health_max

@export var animation_player : Node

enum States { INITIALIZING, PAUSED, IDLE, RUNNING, JUMPING, KNOCKBACK, IFRAMES, ATTACKING, DYING, DEAD }
var State = States.INITIALIZING
var animations = ["", "", "idle", "run", "jump", "hurt", "hurt", "attack", "die"]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction : int = 1
var decision_wait_time = 1.0 # seconds

var player



@onready var decision_timer : Timer = $Behaviours/DecisionMaking/DecisionTimer

signal hurt
signal died(name)

func _ready():
	if !animation_player:
		animation_player = $AnimationPlayer
	#$AnimationPlayer.play("RESET")
	velocity = Vector2.RIGHT * SPEED
	hurt.connect(StageManager._on_damage_packet_processed)
	died.connect(StageManager._on_NPC_died)
	
	#var owner = get_owner()
	if (owner and owner.has_method("_on_NPC_died")):
		owner.num_enemies += 1
		died.connect(owner._on_NPC_died)
	
	player = StageManager.current_player
	
	
func activate():
	if State == States.INITIALIZING: # ie: not DEAD (don't revive cleared enemies)
		set_difficulty(Globals.difficulty)
		activate_weapons()
		State = States.IDLE
		decision_timer.start()
	
func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 5.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)

func activate_weapons():
	for weapon in $Behaviours/Attacks.get_children():
		if weapon.get("enabled") == true:
			if weapon.has_method("activate"):
				weapon.activate()
			if weapon.has_method("start"):
				weapon.start() # needed for basic shooting weapon

func jump():
	velocity.y = JUMP_VELOCITY


func _physics_process(delta):
	if State in [ States.RUNNING, States.JUMPING, States.IDLE, States.ATTACKING ]:
		apply_gravity(delta)
		sync_to_moving_platform(delta)
		move_and_slide()
		update_animations()
		if is_on_top_of_player():
			jump()
		elif is_on_floor() and is_at_end_of_platform() or is_obstructed():
			turn_around()
		
	elif State in [States.KNOCKBACK, States.IFRAMES]:
		# no downward gravity during knockback.
		move_and_slide()

	elif State in [States.DYING, States.DEAD]:
		# don't hover in space after dying
		if is_on_floor():
			velocity = Vector2.ZERO
		else:
			apply_gravity(delta)
			sync_to_moving_platform(delta)
			move_and_slide()
		
	$Debug/StateLabel.text = States.keys()[State]

func sync_to_moving_platform(_delta):
	var sensor : RayCast2D = $Behaviours/Sensors/MovingPlatformSensor
	if sensor.is_colliding():
		var thing_underfoot = sensor.get_collider()
		if is_on_floor() and thing_underfoot.is_in_group("MovingPlatforms"):
			if thing_underfoot.owner.get("velocity") != null:
				velocity.y = thing_underfoot.owner.velocity.y
			
			
func is_at_end_of_platform():
		if is_on_floor() and !$Behaviours/Sensors/FloorSensor.is_colliding():
			return true

func is_obstructed():
	if $Behaviours/Sensors/ObstacleSensor.is_colliding():
		return true
	
func is_on_top_of_player():
	var area : Area2D = $Behaviours/Sensors/PlayerSensor
	if area.get_overlapping_bodies().has(get_tree().get_first_node_in_group("Player")):
		return true


func update_animations():
	if animation_player.current_animation == "":
		if animations[State] != "" and animation_player.has_animation(animations[State]):
			animation_player.play(animations[State])

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func play_death_tween_if_needed():
	var tween = create_tween()
	tween.parallel().tween_property(self, "rotation", PI * 0.5, 0.33)
	tween.parallel().tween_property(self, "position", position + Vector2(0, 5), 0.33)

func die():
	State = States.DEAD
	play_death_animation() # should include audio
	#decision_timer.stop()
	abort_attacks_in_progress()
	disable_collision_layers_and_masks()
	died.emit(name)
	stop_all_timers()

func stop_all_timers():
	$Behaviours/DecisionMaking/DecisionTimer.stop()
	$Behaviours/Attacks/SimpleMeleeAttack/AttackDelay.stop()
	$Behaviours/Attacks/SimpleMeleeAttack/AttackReload.stop()
	$Behaviours/Attacks/SimpleShootAttack/RecoilTimer.stop()
	$Behaviours/Attacks/SimpleShootAttack/ReloadTimer.stop()
	$IframesTimer.stop()

func play_death_animation():
	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("die"):
		$AnimationPlayer.play("die")
	else:
		play_death_tween_if_needed()


func disable_collision_layers_and_masks():
	set_collision_layer_value(2, false)
	for layer in [1, 2, 3]:
		set_collision_mask_value(layer, false)


func _on_hit(attackPacket : AttackPacket):
	if State in [ States.DYING, States.DEAD ]:
		return
	elif State in [States.RUNNING, States.JUMPING, States.IDLE, States.ATTACKING]:
		$HurtNoises.play()
		abort_attacks_in_progress()
		health -= attackPacket.damage
		# if health <= 0, they'll die after they return from iframes.
		
		if attackPacket.knockback == true:
			State = States.KNOCKBACK # same as IFRAMES, plus movement.
			var knockbackMultiplier = 1.25
			velocity = attackPacket.impact_vector * attackPacket.knockback_speed * knockbackMultiplier
		else: # no knockback
			State = States.IFRAMES
		$IframesTimer.start()
		$AnimationPlayer.play("hurt")
			#$HurtEffect/Star.show()
		hurt.emit(attackPacket)


func abort_attacks_in_progress():
	for attack in $Behaviours/Attacks.get_children():
		if attack.get("enabled") == true and attack.has_method("stop"):
			attack.stop()
	

func resume_attacking():
	if State not in [ States.DYING, States.DEAD ]:
		for attack in $Behaviours/Attacks.get_children():
			if attack.get("enabled") == true and attack.has_method("start"):
				attack.start()

func _on_iframes_timer_timeout():
	if State in [States.DYING, States.DEAD]:
		return
		
	elif health <= 0:
		die()
		return
		
	elif State in [States.KNOCKBACK, States.IFRAMES]:
		#$HurtEffect/Star.hide()
		#$Appearance/Sprite2D.material.set_shader_parameter("IFrames", false)
		if velocity.x > 0:
			velocity = Vector2.RIGHT * SPEED
		else:
			velocity = Vector2.LEFT * SPEED

		State = States.RUNNING
		$AnimationPlayer.play("RESET")
		resume_attacking()

func turn_around():
	
	direction = -direction
	if State == States.RUNNING:
		velocity.x = SPEED * direction
		#velocity.x = clamp(velocity.x, -SPEED, SPEED )
	
	$Appearance.scale.x = direction
	$Behaviours.scale.x = direction


func _on_decision_timer_timeout():
	if State not in [ States.DYING, States.DEAD ]:
		choose_new_behaviour()

func choose_new_behaviour():
	# run back and forth, but favour running toward the player
	select_random_state()

	# don't need to set state to attacking. The attack behaviours will handle that
	if State == States.RUNNING:
		select_random_direction()
		animation_player.play("run")
		velocity.x = direction * SPEED

	elif State == States.IDLE:
		animation_player.play("idle")
		velocity.x = 0

	decision_timer.set_wait_time(decision_wait_time * randf_range(0.8, 1.25))
	decision_timer.start()


func select_random_state():
	
	if State in [ States.IDLE, States.RUNNING ]:
		var contender_states = [ States.IDLE, States.RUNNING ]
		var probabilities = [ 0.1, 0.9 ]
		var dice_roll = randf()
		var cumulative_chance = 0.0
		for i in range(contender_states.size()):
			cumulative_chance += probabilities[i]
			if dice_roll < cumulative_chance:
				State = contender_states[i]
				dice_roll = 100.0 # so it won't trigger subsequent states

func select_random_direction():
	
	var chance_to_turn_around
	var dir_to_player = sign(global_position.direction_to(player.global_position).x)
	if dir_to_player == direction: # already going the correct way
		chance_to_turn_around = 0.15
	else: # facing the wrong way
		chance_to_turn_around = 0.66
	if randf() < chance_to_turn_around:
		turn_around()


func _on_shot_requested():
	if State not in [States.DYING, States.DEAD]:
		State = States.ATTACKING
		velocity.x = 0
		if animation_player.has_animation("shoot"):
			animation_player.play("shoot")
			# note: the shoot animation needs to call launch_bullet() on the simple shooter node.



func _on_animation_player_animation_finished(anim_name):
	if State in [ States.DYING, States.DEAD ]:
		return
	
	elif anim_name in ["shoot", "attack"]:
		State = States.IDLE
		velocity.x = 0
		decision_timer.stop()
		choose_new_behaviour()
		
