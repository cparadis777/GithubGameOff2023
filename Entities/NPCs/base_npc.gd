extends CharacterBody2D


@export var SPEED : float = 40.0
@export var JUMP_VELOCITY : float = -100.0
@export var base_damage : float = 10

@export var health_max = 50.0
var health = health_max

@export var animation_player : Node

enum States { INITIALIZING, PAUSED, IDLE, RUNNING, JUMPING, KNOCKBACK, IFRAMES, ATTACKING, DEAD }
var State = States.INITIALIZING
var animations = ["", "", "idle", "run", "jump", "hurt", "hurt", "attack", "die"]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction : int = 1

@onready var decision_timer : Timer = $Behaviours/DecisionMaking/DecisionTimer

signal hurt
signal died(name)

func _ready():
	if !animation_player:
		animation_player = $AnimationPlayer
	$AnimationPlayer.play("RESET")
	velocity = Vector2.RIGHT * SPEED
	hurt.connect(StageManager._on_damage_packet_processed)
	died.connect(StageManager._on_NPC_died)
	
	#var owner = get_owner()
	if (owner and owner.has_method("_on_NPC_died")):
		owner.num_enemies += 1
		died.connect(owner._on_NPC_died)
	
	
	
func activate():
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
		if is_at_end_of_platform() or is_obstructed():
			turn_around()
	elif State in [States.KNOCKBACK, States.IFRAMES]:
		# no downward gravity during knockback.
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
	if has_node("AnimationPlayer"):
		if $AnimationPlayer.has_animation("die"):
			#$AnimationPlayer.stop()
			$AnimationPlayer.play("die")
		else:
			play_death_tween_if_needed()
	else:
		play_death_tween_if_needed()
	decision_timer.stop()
	$CollisionShape2D.call_deferred("set_disabled", true)
	died.emit(name)

func _on_hit(attackPacket : AttackPacket):
	if State in [States.RUNNING, States.JUMPING, States.IDLE, States.ATTACKING]:
		$HurtNoises.play()
		abort_attacks_in_progress()
		health -= attackPacket.damage
		if health <= 0:
			die()
			return
		elif attackPacket.knockback == true:
			State = States.KNOCKBACK # same as IFRAMES, plus movement.
			var knockbackMultiplier = 1.25
			velocity = attackPacket.impact_vector * attackPacket.knockback_speed * knockbackMultiplier
		else:
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
	for attack in $Behaviours/Attacks.get_children():
		if attack.get("enabled") == true and attack.has_method("start"):
			attack.start()

func _on_iframes_timer_timeout():
	if State in [States.KNOCKBACK, States.IFRAMES]:
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
	choose_new_behaviour()

func choose_new_behaviour():
	if State in [ States.IDLE, States.RUNNING ]:
		State = [States.IDLE, States.RUNNING].pick_random()
		# don't need to set state to attacking. The attack behaviours will handle that
		if State == States.RUNNING:
			animation_player.play("run")
			velocity.x = direction * SPEED
			if randf()<0.33:
				turn_around()
		elif State == States.IDLE:
			animation_player.play("idle")
			velocity.x = 0
		decision_timer.start()

func _on_shot_requested():
	State = States.ATTACKING
	velocity.x = 0
	if animation_player.has_animation("shoot"):
		animation_player.play("shoot")
		# note: the shoot animation needs to call launch_bullet() on the simple shooter node.



func _on_animation_player_animation_finished(anim_name):
	if anim_name in ["shoot", "attack"]:
		State = States.IDLE
		velocity.x = 0
		decision_timer.stop()
		choose_new_behaviour()
		
