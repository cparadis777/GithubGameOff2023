# use to generate a vector towards the player, which you can then
# add to other vectors (like gravity, whatever) before move_and_slide()


extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var original_doll_scale : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var health_max = 200
@onready var health = health_max

var avatar_root : Node2D

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
	
	if has_node("Sprites"):
		avatar_root = $Sprites
	elif has_node("PaperDoll"):
		avatar_root = $PaperDoll.scale
	original_doll_scale = avatar_root.scale
	
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
		apply_gravity(delta)
		move_and_slide()
	elif State in [States.IDLE, States.IFRAMES]:
		# no new horizontal movement
		apply_gravity(delta)
		move_and_slide()


func apply_gravity(delta):
	# consider adding an escape if State == States.IFRAMES
	
	if not is_on_floor():
		velocity.y += gravity * delta
	

func update_animations():
	avatar_root.scale.x = signf(velocity.x) * original_doll_scale.x
	$Behaviours.scale.x = signf(velocity.x)
	if abs(velocity.x) > 0:
		var anim = $AnimationPlayer.current_animation
		if anim == "":
			$AnimationPlayer.play("walk")

func begin_dying():
	print("dockworker dying")
	State = States.DYING
	$AnimationPlayer.play("die")
	$HitBox.set_deferred("disabled", true)

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
	var magnitude = 66.0 # two thirds as much as a regular NPC
	velocity = knockbackVector * magnitude


	
func _on_hit(attackPacket : AttackPacket):
	if not State in [ States.DYING, States.DEAD, States.INITIALIZING, States.IFRAMES ]:

		health -= attackPacket.damage
		if health <= 0:
			begin_dying()
		else:
			play_hurt_noise()
			#$HurtFlash.show()
			$AnimationPlayer.play("hurt")
			initiate_iframes()
			if attackPacket.knockback:
				knockback(attackPacket.impact_vector)


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
	State = previous_state
	$HurtFlash.hide()

