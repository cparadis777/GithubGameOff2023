# use to generate a vector towards the player, which you can then
# add to other vectors (like gravity, whatever) before move_and_slide()


extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var original_doll_scale : Vector2
var last_known_direction : int = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var health_max = 200
@onready var health = health_max

@onready var animation_player = $AnimationPlayer
var avatar_root : Node2D

@onready var player = StageManager.current_player
enum Goals { ATTACK, DEFEND } # add RELAX, RELOCATE later.
var current_goal = Goals.ATTACK

enum States { INITIALIZING, PAUSED, IDLE, ALERT, IFRAMES, DEFENDING, DYING, DEAD }
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
	$Behaviours/Defenses/ArmShieldDefense.activate()
	
	if has_node("Sprites"):
		avatar_root = $Sprites
	elif has_node("PaperDoll"):
		avatar_root = $PaperDoll.scale
	original_doll_scale = avatar_root.scale
	
	State = States.ALERT
	$HurtFlash.hide()

	$DecisionTimer.start()

func activate():
	# consider putting the DecisionTimer start in here.
	# that will let levels spawn without paused NPCs
	pass
	

func _physics_process(delta):
	if State == States.ALERT:
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
				velocity += movement.get_movement_vector(delta)
		update_animations()
		apply_gravity(delta)
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

func point_at_player():
		
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
	if State in [ States.IDLE, States.ALERT ]:

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
	elif State == States.DEFENDING:
		# play a symbol clash noise or something.
		# maybe knock back the player
		$Behaviours/Defenses/ArmShieldDefense._on_hit(attackPacket)
		

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



func _on_decision_timer_timeout():
	current_goal = Goals.values().pick_random()
