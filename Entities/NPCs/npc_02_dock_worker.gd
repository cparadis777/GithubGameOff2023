# use to generate a vector towards the player, which you can then
# add to other vectors (like gravity, whatever) before move_and_slide()


extends CharacterBody2D

@export var damage_to_block : float = 80

var SPEED = 300.0
var JUMP_VELOCITY = -400.0
var base_damage = 10

var original_doll_scale : Vector2
var last_known_direction : int = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var health_max = 250
@onready var health = health_max

@onready var animation_player = $AnimationPlayer
var avatar_root : Node2D

@onready var player = StageManager.current_player
enum Goals { ATTACK, DEFEND } # add RELAX, RELOCATE later.
var current_goal = Goals.ATTACK

enum States { INITIALIZING, PAUSED, IDLE, ALERT, IFRAMES, DEFENDING, DYING, DEAD }
var animations = ["", "", "idle", "walk", "hurt", "defend", "die", ""]
var State :States = States.INITIALIZING :
	set(value):
		previous_state = State
		State = value
	get:
		return State

signal hurt(attackPacket)
signal died(name)


var previous_state : States

func _ready():
	$Behaviours/Movement/WalkTowardPlayer.activate()
	$Behaviours/Attacks/HeavyMeleeAttack.activate()
	$Behaviours/Defenses/ArmShieldDefense.activate()
	
	$Sprites/Corpse.hide()
	
	if has_node("Sprites"):
		avatar_root = $Sprites
	elif has_node("PaperDoll"):
		avatar_root = $PaperDoll.scale
	original_doll_scale = avatar_root.scale
	
	$HurtFlash.hide()

	$DecisionTimer.start()

	hurt.connect(StageManager._on_damage_packet_processed)
	died.connect(StageManager._on_NPC_died)

	if (owner and owner.has_method("_on_NPC_died")):
		owner.num_enemies += 1
		died.connect(owner._on_NPC_died)

func activate():
	if State == States.INITIALIZING:
		State = States.ALERT
		set_difficulty(Globals.difficulty)
		$DecisionTimer.start()

func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 5.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)

func _physics_process(delta):
	if State in [ States.DYING, States.DEAD]:
		velocity.x = 0
		apply_gravity(delta)
		sync_to_moving_platforms(delta)
		move_and_slide()
		return
		
	elif State == States.ALERT:
		if current_goal == Goals.ATTACK:
			for attack in $Behaviours/Attacks.get_children():
				if attack.has_method("is_active") and attack.is_active():
					attack.attempt_to_attack()
		elif current_goal == Goals.DEFEND:
			for defense in $Behaviours/Defenses.get_children():
				if defense.has_method("is_active") and defense.is_active():
					defense.attempt_to_defend()
			
		for movement in $Behaviours/Movement.get_children():
			if movement.is_active():
				if $Behaviours/Movement/WalkTowardPlayer/CliffSensor.is_colliding():
					velocity += movement.get_movement_vector(delta)
		update_animations()
		apply_gravity(delta)
		sync_to_moving_platforms(delta)
		move_and_slide()
	elif State in [States.IDLE, States.IFRAMES]:
		# no new horizontal movement
		apply_gravity(delta)
		move_and_slide()
	elif State == States.DEFENDING:
		point_at_player()
		flip_sprites()

	
	if velocity.x != 0:
		last_known_direction = sign(velocity.x)

func apply_gravity(delta):
	# consider adding an escape if State == States.IFRAMES
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0 # could impede jumping ability
	
func sync_to_moving_platforms(_delta):
	var sensor : RayCast2D = $Behaviours/Movement/WalkTowardPlayer/PlatformSensor
	if sensor.is_colliding():
		var thing_underfoot = sensor.get_collider()
		if is_on_floor() and thing_underfoot != null and thing_underfoot.is_in_group("MovingPlatforms"):
			if thing_underfoot.owner.get("velocity") != null:
				velocity.y = thing_underfoot.owner.velocity.y
			
	
	
func point_at_player():
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	
	if player != null and is_instance_valid(player):
		if global_position.x < player.global_position.x:
			velocity.x = abs(velocity.x) * 1
		else:
			velocity.x = abs(velocity.x) * -1

		if velocity.x == 0:
			last_known_direction = sign(player.global_position.x - global_position.x)


func flip_sprites():
	avatar_root.scale.x = last_known_direction * original_doll_scale.x
	$Behaviours.scale.x = last_known_direction
	

func update_animations():
	flip_sprites()
	if abs(velocity.x) > 0:
		var anim = $AnimationPlayer.current_animation
		if anim == "":
			$AnimationPlayer.play("walk")

func begin_dying():
	disable_all_timers()
	State = States.DEAD
	died.emit(name)
	#$AnimationPlayer.play("die")
	#$HitBox.set_deferred("disabled", true)
	set_collision_layer_value(2, false)
	
	set_collision_mask_value(1, false) # player
	set_collision_mask_value(2, false) # other NPCs
	spawn_corpse()
	call_deferred("queue_free")
	
	
func spawn_corpse():
	var new_corpse = $Sprites/Corpse.duplicate()
	add_sibling(new_corpse)
	new_corpse.global_position = global_position
	new_corpse.activate()

func disable_all_timers():
	var timers = find_children("", "Timer")
	for timer in timers:
		timer.stop()
	
	

func begin_decaying():
	State = States.DEAD
	#$AnimationPlayer.play("die")
	$DecayTimer.start()
	


func initiate_iframes():
	previous_state = State
	State = States.IFRAMES
	$IFramesTimer.start()

#func play_hurt_noise():
#	$HurtNoises.play()

func knockback(knockbackVector):
	var magnitude = 1.0 # two thirds as much as a regular NPC
	if State in [States.DEFENDING]:
		magnitude = 0.25
	velocity = knockbackVector * magnitude


	
func _on_hit(attackPacket : AttackPacket):
	if State in [States.DYING, States.DEAD]:
		return
		
	elif State in [ States.IDLE, States.ALERT ]: # no defensive block

		health -= attackPacket.damage
		hurt.emit(attackPacket)

		$AnimationPlayer.play("hurt")
		if attackPacket.knockback:
			knockback(attackPacket.impact_vector * attackPacket.knockback_speed)
		initiate_iframes() # after knockback
	
	elif State == States.DEFENDING: # remove some damage from the attack
		attackPacket.damage_blocked = min(attackPacket.damage, damage_to_block)
		hurt.emit(attackPacket)
		
		if attackPacket.damage_blocked >= attackPacket.damage:
			# no health reduction
			$Behaviours/Defenses/ArmShieldDefense._on_hit(attackPacket)

		else: # some damage got through
			health -= (attackPacket.damage - attackPacket.damage_blocked)
			$AnimationPlayer.play("hurt")
			$Behaviours/Attacks/HeavyMeleeAttack.stop()
			if attackPacket.knockback:
				knockback(attackPacket.impact_vector)
			initiate_iframes() # after knockback


func _on_decay_timer_timeout():
	avatar_root.hide()
	$BloodTimer.start()


func _on_blood_timer_timeout():
	call_deferred("queue_free")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		begin_decaying()
	elif anim_name == "melee_attack":
		pass # handled in update_animations() already.


func _on_i_frames_timer_timeout():
	assert(State == States.IFRAMES, "dock worker iframes timeout but State != iframes. State == " + States.keys()[State])
	if State not in [States.DYING, States.DEAD]:
		$HurtFlash.hide()
		if health <= 0.0:
			begin_dying()
		else:
			State = previous_state
		


func _on_decision_timer_timeout():
	if State not in [ States.DYING, States.DEAD, States.IFRAMES ]:
		current_goal = Goals.values().pick_random()
		$DecisionTimer.start()
