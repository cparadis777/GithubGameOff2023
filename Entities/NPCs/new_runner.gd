extends CharacterBody2D

var health_max = 100
var health = health_max
var base_damage = 10

var SPEED = 100.0
var JUMP_VELOCITY = -200.0
var kick_speed_multiplier = 3.0

enum States { INITIALIZING, RUNNING, JUMPING, IDLE, ATTACKING, IFRAMES, DEAD }
var State : States = States.INITIALIZING:
	set(value):
		previous_state = State
		State = value
		_on_state_changed(previous_state, value)
	get:
		return State
var previous_state : States

var direction : int = 1
var floor_last_frame : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal hurt(attackPacket)
signal hit(attackPacket) # ie: hit someone else


func _ready():
	
	
	hurt.connect(StageManager._on_damage_packet_processed)
	
#	await get_tree().create_timer(1.0).timeout
#	if StageManager.current_level == null:
#		activate()
	$AnimationPlayer.play("RESET")

func activate():
	if State == States.INITIALIZING:
		set_difficulty(Globals.difficulty)
		State = States.RUNNING
		$DecisionTimer.start()
	
func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 5.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)	

func _physics_process(delta):
	apply_gravity(delta) # all states
	sync_motion_to_platforms(delta) # all states
	if State == States.RUNNING:
		if direction != 0:
			velocity.x = direction * SPEED
			$AnimatedSprite2D.scale.x = direction
			detect_obstacles_and_cliffs(delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	elif State == States.ATTACKING:
		velocity.x = direction * SPEED * kick_speed_multiplier
	elif State == States.DEAD:
		velocity.x = 0
	elif State == States.IDLE:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif State == States.JUMPING:
		if velocity.y > 0 and is_on_floor():
			land()
	
	
	move_and_slide() # all states

func detect_obstacles_and_cliffs(_delta):
	if State == States.DEAD:
		return
		
	elif State == States.RUNNING and is_on_floor():
		if (
			not $Sensors/CliffDetector.is_colliding() # cliff
			or  $Sensors/ObstacleDetector.is_colliding() # obstacle
			):
				if randf() < 0.85:
					turn_around()
				else:
					jump()

func sync_motion_to_platforms(_delta):
	var potential_platform = $Sensors/PlatformDetector.get_collider()
	if potential_platform != null and potential_platform.is_in_group("MovingPlatforms"):
		if potential_platform.owner.get("velocity"):
			velocity.y = potential_platform.owner.velocity.y

func apply_gravity(delta):
	if not is_on_floor(): # all states
		velocity.y += gravity * delta
	
	if State == States.JUMPING:
		if is_on_floor() and not floor_last_frame: # don't prevent new jumps
			land()
			
	floor_last_frame = is_on_floor()
	
func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		State = States.JUMPING

func land():
	State = States.RUNNING
	velocity.y = 0

func idle():
	State = States.IDLE
	
	
func attack():
	State = States.ATTACKING

func run():
	State = States.RUNNING
	
func turn_around():
	direction *= -1



func choose_new_behaviour():
	randomize()
	var random_nums = [ randf(), randf(), randf(), randf() ]

	var movement_roll = random_nums.pop_back()
	if movement_roll < 0.1:
		idle()
	elif movement_roll < 0.2 and is_on_floor():
		jump()
	else: # 70%
		run()

	var turn_around_roll = random_nums.pop_back()
	if is_facing_player() and turn_around_roll < 0.1:
		turn_around()
	elif not is_facing_player() and turn_around_roll < 0.75:
		turn_around()
	
	var engagement_roll = random_nums.pop_back()
	if is_facing_player() and engagement_roll < 0.67:
		attack()


func is_facing_player():
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	if player.global_position.x > global_position.x:
		return true
	else:
		return false


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"attack":
			State = States.RUNNING
		"hurt":
			if health <= 0:
				State = States.DEAD
			else:
				State = States.RUNNING
		
func disable_hurtbox():
	$AnimatedSprite2D/Hurtbox.monitoring = false

func hide_hurtflash():
	$AnimatedSprite2D.material.set_shader_parameter("iframes", false)
	
func _on_state_changed(prev_state, new_state):
	if prev_state == States.ATTACKING:
		disable_hurtbox()
	elif prev_state == States.IFRAMES:
		hide_hurtflash()
		
	match new_state:
		States.RUNNING:
			$AnimationPlayer.play("run")
		States.ATTACKING:
			$AnimationPlayer.play("attack")
		States.DEAD:
			$DecisionTimer.stop()
			velocity.x = 0
			$AnimationPlayer.play("die")
		States.IFRAMES:
			$AnimationPlayer.play("hurt")
	$StateLabel.text = States.keys()[State]
	
	
func _on_hit(attackPacket : AttackPacket):
	if State not in [ States.INITIALIZING, States.DEAD, States.IFRAMES ]:
		health -= attackPacket.damage
		#velocity = attackPacket.impact_vector * attackPacket.knockback_speed
		hurt.emit(attackPacket)
		State = States.IFRAMES
		


func _on_hurtbox_body_entered(body):
	if body == StageManager.current_player:
		var attackPacket : AttackPacket = AttackPacket.new()
		attackPacket.originator = self
		attackPacket.recipient = body
		attackPacket.impact_vector = global_position.direction_to(body.global_position)
		attackPacket.knockback = true
		attackPacket.knockback_speed = 100.0
		hit.connect(body._on_hit)
		hit.emit(attackPacket)
		hit.disconnect(body._on_hit)


func _on_decision_timer_timeout():
	if State in [ States.DEAD ]:
		velocity.x = 0
		$DecisionTimer.stop()
		return
	
	elif State in [States.RUNNING, States.JUMPING, States.IDLE ]:
		choose_new_behaviour()

	$DecisionTimer.start()
