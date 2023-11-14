extends CharacterBody2D


@export var SPEED : float = 40.0
@export var JUMP_VELOCITY : float = -100.0
@export var base_damage : float = 10

@export var health_max = 250.0
var health = health_max

@export var animation_player : Node

enum States { INITIALIZING, IDLE, PAUSED, RUNNING, JUMPING, KNOCKBACK, ATTACKING, DEAD }
var State = States.INITIALIZING
var animations = ["run", "jump", "hurt", "attack", "die"]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal hurt
signal died

func _ready():
	if !animation_player:
		animation_player = $AnimationPlayer
	$AnimationPlayer.play("RESET")
	velocity = Vector2.RIGHT * SPEED
	hurt.connect(StageManager._on_damage_packet_processed)
	died.connect(StageManager._on_NPC_died)

	# temporary, until we get NPC spawning and activating
	State = States.IDLE

func activate(difficulty : Globals.DifficultyScales):
	set_difficulty(difficulty)
	State = States.RUNNING
	
func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 5.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)

func jump():
	velocity.y = JUMP_VELOCITY


func _physics_process(delta):
	if State in [ States.RUNNING, States.JUMPING ]:
		apply_gravity(delta)
		move_and_slide()
		update_animations()
	elif State == States.KNOCKBACK:
		move_and_slide()


func update_animations():
	if animation_player.current_animation == "":
		if animation_player.has_animation(animations[State]):
			animation_player.play(animations[State])

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		


func die():
	State = States.DEAD
	var tween = create_tween()
	tween.parallel().tween_property(self, "rotation", PI * 0.5, 0.33)
	tween.parallel().tween_property(self, "position", position + Vector2(0, 5), 0.33)
	$DecisionTimer.stop()
	$CollisionShape2D.call_deferred("set_disabled", true)
	died.emit(name)

func _on_hit(attackPacket : AttackPacket):
	if State in [States.RUNNING, States.JUMPING, States.IDLE]:
		$HurtNoises.play()
		health -= attackPacket.damage
		if health <= 0:
			die()
			return
		elif attackPacket.knockback == true:
			State = States.KNOCKBACK
			var knockbackMultiplier = 1.25
			velocity = attackPacket.impact_vector * attackPacket.knockback_speed * knockbackMultiplier
		$IframesTimer.start()
		$AnimationPlayer.play("hurt")
			#$HurtEffect/Star.show()
		hurt.emit(attackPacket)

func _on_iframes_timer_timeout():
	if State == States.KNOCKBACK:
		$HurtEffect/Star.hide()
		if velocity.x > 0:
			velocity = Vector2.RIGHT * SPEED
		else:
			velocity = Vector2.LEFT * SPEED

		State = States.RUNNING


func _on_decision_timer_timeout():
	if State in [ States.IDLE, States.RUNNING ]:
		State = [States.IDLE, States.RUNNING].pick_random()

		if State == States.RUNNING:
			animation_player.play("run")
			velocity = -velocity.clamp(Vector2.LEFT * SPEED, Vector2.RIGHT * SPEED )
			if abs(velocity.x) > 0:
				$Appearance.scale.x = sign(velocity.x)
		elif State == States.IDLE:
			animation_player.play("idle")
