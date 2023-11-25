extends CharacterBody2D

var health_max = 100
var health = health_max
var base_damage = 10

var SPEED = 100.0
const JUMP_VELOCITY = -400.0

enum States { INITIALIZING, RUNNING, JUMPING, ATTACKING, IFRAMES, DEAD }
var State : States = States.INITIALIZING:
	set(value):
		State = value
		_on_state_changed(value)
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
	randomize()
	
	hurt.connect(StageManager._on_damage_packet_processed)
	
	await get_tree().create_timer(1.0).timeout
	if StageManager.current_level == null:
		activate()
		

func activate():
	State = States.RUNNING
	$DecisionTimer.start()
	
func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 5.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)	

func _physics_process(delta):
	apply_gravity(delta)

	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if State == States.ATTACKING:
		velocity.x *= 3.0

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor(): # in the air
		velocity.y += gravity * delta
		
	elif is_on_floor and not floor_last_frame: # don't prevent jumping
		#just landed
		State = States.RUNNING
		velocity.y = 0
		
	floor_last_frame = is_on_floor()
	
func jump():
	velocity.y = JUMP_VELOCITY
	State = States.JUMPING

func attack():
	State = States.ATTACKING

func turn_around():
	direction *= -1

func _on_decision_timer_timeout():
	if State == States.RUNNING:
		var player = get_tree().get_first_node_in_group("Player")
		if player != null:
			var dir_to_player
			if player.global_position.x > global_position.x:
				dir_to_player = 1
			else:
				dir_to_player = -1
			if direction != dir_to_player and randf() < 0.85:
				turn_around()
			elif direction == dir_to_player and randf() < 0.75:
				if randf() < 0.8:
					attack()
				else: # 0.2
					turn_around()
			elif randf() < 0.5:
				jump()
	$DecisionTimer.start()

	
	
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"attack":
			State = States.RUNNING
		"hurt":
			if health <= 0:
				State = States.DEAD
			else:
				State = States.RUNNING
		
		
func _on_state_changed(new_state):
	match new_state:
		States.RUNNING:
			$AnimationPlayer.play("run")
		States.ATTACKING:
			$AnimationPlayer.play("attack")
		States.DEAD:
			$DecisionTimer.stop()
			velocity.x = 0
			$AnimationPlayer.play("die")
	$StateLabel.text = States.keys()[State]
	
	
func _on_hit(attackPacket):
	if State != States.DEAD:
		$AnimationPlayer.play("hurt")
		health -= attackPacket.damage
		hurt.emit(attackPacket)
		


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
	
