extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var original_doll_scale : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var health_max = 100
@onready var health = health_max

enum States { INITIALIZING, PAUSED, IDLE, ALERT, IFRAMES, DYING, DEAD }
var State :States = States.INITIALIZING :
	set(value):
		previous_state = State
		State = value
	get:
		return State

var previous_state : States

func _ready():
	$Behaviours/Movement/WalkTowardPlayer.activate()
	$Behaviours/Attacks/HeavyMeleeAttack.activate()
	
	original_doll_scale = $PaperDoll.scale
	State = States.ALERT
	$HurtFlash.hide()

func _physics_process(delta):
	if State == States.ALERT:
		for attack in $Behaviours/Attacks.get_children():
			if attack.has_method("is_active") and attack.is_active():
				attack.attempt_to_attack()
		
		for movement in $Behaviours/Movement.get_children():
			if movement.is_active():
				velocity += movement.get_movement_vector(delta)
		update_animations()
		#print("dock worker velocity: " + str(velocity))
		move_and_slide()
	elif State == States.IDLE:
		move_and_slide() # required for standing on moving platforms
	elif State == States.IFRAMES:
		move_and_slide() # don't change velocity, just go.

func update_animations():
	$PaperDoll.scale.x = signf(velocity.x) * original_doll_scale.x
	if abs(velocity.x) > 0:
		var anim = $AnimationPlayer.current_animation
		if anim == "":
			$AnimationPlayer.play("walk")

func begin_dying():
	print("dockworker dying")
	State = States.DYING
	$AnimationPlayer.play("die")


func begin_decaying():
	State = States.DEAD
	$DecayTimer.start()


func initiate_iframes():
	previous_state = State
	State = States.IFRAMES
	$IFramesTimer.start()

func play_hurt_noise():
	$HurtNoises.play()

func knockback(knockbackVector):
	var magnitude = 10.0
	velocity = knockbackVector * magnitude
	
func _on_hit(damage, _impactVector, _damageType, _knockback):
	if not State in [ States.DYING, States.DEAD, States.INITIALIZING, States.IFRAMES ]:
		health -= damage
		if health <= 0:
			begin_dying()
		else:
			play_hurt_noise()
			#$HurtFlash.show()
			$AnimationPlayer.play("hurt")
			initiate_iframes()
			if _knockback:
				knockback(_impactVector)



func _on_decay_timer_timeout():
	$PaperDoll.hide()
	$BloodTimer.start()


func _on_blood_timer_timeout():
	call_deferred("queue_free")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "die":
		begin_decaying()


func _on_i_frames_timer_timeout():
	State = previous_state
	$HurtFlash.hide()
