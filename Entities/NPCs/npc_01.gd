extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

enum States { ROLLING, JUMPING, ATTACKING, DEAD }
var State = States.ROLLING


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	velocity = Vector2.RIGHT * SPEED

func jump():
	velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	if State in [ States.ROLLING, States.JUMPING ]:
		apply_gravity(delta)
		move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func _on_timer_timeout():
	if State in [ States.ROLLING ]:
		$Appearance.scale.x = -$Appearance.scale.x
		velocity = -velocity


func die():
	State = States.DEAD
	var tween = create_tween()
	tween.parallel().tween_property(self, "rotation", PI * 0.5, 0.33)
	tween.parallel().tween_property(self, "position", position + Vector2(0, 20), 0.33)
	$Timer.stop()
	$CollisionShape2D.call_deferred("set_disabled", true)

func _on_hit():
	if State in [States.ROLLING, States.JUMPING]:
		die()
	
