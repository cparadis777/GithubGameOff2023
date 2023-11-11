extends CharacterBody2D


@export var SPEED = 40.0
@export var JUMP_VELOCITY = -100.0

@export var health_max = 30.0
var health = health_max


enum States { ROLLING, JUMPING, KNOCKBACK, ATTACKING, DEAD }
var State = States.ROLLING


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity = Vector2.RIGHT * SPEED
	$HurtEffect/Star.hide()


func jump():
	velocity.y = JUMP_VELOCITY


func _physics_process(delta):
	if State in [ States.ROLLING, States.JUMPING ]:
		apply_gravity(delta)
		move_and_slide()
	elif State == States.KNOCKBACK:
		move_and_slide()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func _on_timer_timeout():
	if State in [ States.ROLLING ]:
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


func _on_hit(damage, impactVector, _damageType, knockback):
	if State in [States.ROLLING, States.JUMPING]:
		$HurtNoises.play()
		health -= damage
		if health <= 0:
			die()
			return
		elif knockback == true:
			State = States.KNOCKBACK
			var knockbackSpeed = 250.0
			velocity = impactVector * knockbackSpeed
		$IframesTimer.start()
		$AnimationPlayer.play("hit")
			#$HurtEffect/Star.show()


func _on_iframes_timer_timeout():
	if State == States.KNOCKBACK:
		$HurtEffect/Star.hide()
		if velocity.x > 0:
			velocity = Vector2.RIGHT * SPEED
		else:
			velocity = Vector2.LEFT * SPEED

		State = States.ROLLING
