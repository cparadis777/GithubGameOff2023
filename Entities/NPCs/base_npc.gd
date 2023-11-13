extends CharacterBody2D


@export var SPEED = 40.0
@export var JUMP_VELOCITY = -100.0

@export var health_max = 250.0
var health = health_max

@export var animation_player : Node

enum States { RUNNING, JUMPING, KNOCKBACK, ATTACKING, DEAD }
var State = States.RUNNING
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
		animation_player.play(animations[State])

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func _on_timer_timeout():
	if State in [ States.RUNNING ]:
		velocity = -velocity.clamp(Vector2.LEFT * SPEED, Vector2.RIGHT * SPEED )
		if abs(velocity.x) > 0:
			$Appearance.scale.x = sign(velocity.x)


func die():
	State = States.DEAD
	var tween = create_tween()
	tween.parallel().tween_property(self, "rotation", PI * 0.5, 0.33)
	tween.parallel().tween_property(self, "position", position + Vector2(0, 5), 0.33)
	$DecisionTimer.stop()
	$CollisionShape2D.call_deferred("set_disabled", true)
	died.emit(name)

func _on_hit(attackPacket : AttackPacket):
	if State in [States.RUNNING, States.JUMPING]:
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
