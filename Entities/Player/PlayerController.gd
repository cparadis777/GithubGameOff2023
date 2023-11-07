# Player Controller for 2D action platformer
# move, jump, strong_punch, fast_punch, shoot, interact, etc.


extends CharacterBody2D


@export var SPEED = 150.0
var speed = SPEED # for state machine
@export var JUMP_VELOCITY = 375.0

@onready var camera = $Lookahead/Camera2D
@onready var hud = $HUD
@onready var animation_player = $AnimationPlayer


# relocated to $StateMachine node.. per https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
#enum States { IDLE, RUNNING, JUMPING, ATTACKING }
#var State = States.IDLE
@onready var StateMachine = $StateMachine

var original_body_scale : Vector2
var torso_starting_position : Vector2

signal hit




# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _enter_tree():
	StageManager.current_player = self
	

func _ready():
	$Body/Actions/strong_punch/HurtBox/CollisionShape2D.disabled = true
	$Body/Actions/fast_punch/HurtBox/CollisionShape2D.disabled = true
	$ReferenceRunCycle.hide()
	hud.show()
	
	play_idle_animation()
	original_body_scale = $Body/CyberRoninSprites.scale
	torso_starting_position = $Body/Torso.position

func flip_sprites():
	if Input.is_action_pressed("move_left"):
		$Body.scale.x = -original_body_scale.x
	elif Input.is_action_pressed("move_right"):
		$Body.scale.x = original_body_scale.x
	
func get_last_known_direction():
	if $Body.scale.x > 0:
		return 1
	else:
		return -1

func _physics_process(_delta):
	flip_sprites()
	$Debug.global_rotation = 0.0
	if Input.is_action_just_pressed("shoot"):
		spawn_bullet_toward_mouse()
	elif Input.is_action_just_pressed("debug"):
		initiate_debugging_protocol()
	elif Input.is_action_just_pressed("strong_punch"):
		if $AnimationPlayer.current_animation not in [ "somersault", "fast_punch", "strong_punch", "jump" ]:
			strong_punch()
	elif Input.is_action_just_pressed("fast_punch"):
		if $AnimationPlayer.current_animation not in [ "somersault", "fast_punch", "strong_punch", "jump" ]:
			fast_punch()





func play_run_animation():
	if $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.play("run")
	#$Body/CyberRoninSprites.play("run")

func play_jump_launch_animation():
	$Body/CyberRoninSprites.play("jump_launch")


func play_jump_peak_animation():
	# wait for a signal from Air state
	# includes frames for falling.
	$Body/CyberRoninSprites.play("jump_peak")


func play_idle_animation():
	
#	position.x = floor(position.x)
#	position.y = floor(position.y)
	if $AnimationPlayer.current_animation != "idle":
		$AnimationPlayer.play("idle")
	#$Body/CyberRoninSprites.stop()
	#$Body/CyberRoninSprites.play("idle")

func play_somersault_animation():
	#if $AnimationPlayer.current_animation != "somersault":
		#$AnimationPlayer.play("somersault")
	$Body/CyberRoninSprites.play("double_jump")

func reset_rotation():
	# hack for when state changes during a somersault.
	$Body.rotation = 0
	$Body/Torso.position = torso_starting_position
	animation_player.play("RESET")

func initiate_debugging_protocol():
	if get_viewport().get_camera_2d().zoom == Vector2(1,1):
		get_viewport().get_camera_2d().zoom = Vector2(0.25, 0.25)
	else:
		get_viewport().get_camera_2d().zoom = Vector2(1, 1)

func spawn_bullet_toward_mouse():
	var targetVector = global_position.direction_to(get_global_mouse_position())
	var bulletScene = preload("res://Entities/Projectiles/bullet_basic.tscn")
	var bulletNode = bulletScene.instantiate()
	var muzzleDistance = 15.0
	var heightVector = Vector2(0, -10)
	bulletNode.global_position = global_position + targetVector * muzzleDistance + heightVector
	bulletNode.look_at(targetVector)
	add_sibling(bulletNode)
	bulletNode.activate(targetVector)

func fast_punch():
	if StateMachine.state.name in [ "Idle", "Run" ]:
		if $AnimationPlayer.current_animation not in ["fast_punch", "strong_punch"]:
			$AnimationPlayer.play("fast_punch")
			#$Body/CyberRoninSprites.play("fast_punch")
		
func strong_punch():
	if StateMachine.state.name in [ "Idle", "Run" ]:
		if $AnimationPlayer.current_animation not in [ "fast_punch", "strong_punch"]:
			$AnimationPlayer.play("strong_punch")
			#$Body/CyberRoninSprites.play("strong_punch")


func hurt(body):
	var damage = 10.0
	var impactVector = body.global_position - self.global_position
	var knockback = true
	var damageType = Globals.DamageTypes.IMPACT

	
	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
		hit.emit(damage, impactVector, damageType, knockback)
		hit.disconnect(body._on_hit)


func _on_hurt_box_body_entered(body):
	# TODO: consider splitting this into a separate function for each type of attack
	# strong_punch, fast_punch or descending_kick
	hurt(body)
	if StateMachine.state.name == "DescendingKick":
		velocity.x = -velocity.x * 0.5
		velocity.y = -JUMP_VELOCITY
		StateMachine.transition_to("Air", {do_jump = true})
		
		
		


func _on_animation_player_animation_finished(anim_name):
	if anim_name in [ "fast_punch", "strong_punch" ]:
		if velocity.length_squared() > 0.5:
			play_run_animation()
		else:
			play_idle_animation()
	elif anim_name == "land":
		if StateMachine.state.name == "Run":
			play_run_animation()
		elif StateMachine.state.name == "Idle":
			play_idle_animation()
	

func _on_state_transitioned(stateName):
	match stateName:
		"Air":
			#$old_static_RoninPlaceholderSprite.hide()
			$Body/CyberRoninSprites.stop()
			$Audio/JumpNoises.play()
			
		"Run":
			# see also, signal coming into _on_landed()
			#$old_static_RoninPlaceholderSprite.show()
			if StateMachine.previous_state_name in ["Idle"]:
				play_run_animation()
			elif StateMachine.previous_state_name in ["Air", "DescendingKick", "Dash"]:
				play_run_animation()
				# TODO change this to a landing animation.
				
			
			
		"Idle":
			if StateMachine.previous_state_name in ["Idle"]:
				play_idle_animation()
			elif StateMachine.previous_state_name in ["Air", "DescendingKick", "Dash"]:
				play_idle_animation()
				# TODO change this to a landing animation
			
func _on_jumped(): # from Air state
	play_jump_launch_animation()

func _on_peak_amplitude_reached(): # from Air state
	play_jump_peak_animation()
		
func _on_double_jumped(): # from Air state
	play_somersault_animation()

func _on_landed():
	pass
#	$Body.rotation = 0.0
#	if StateMachine.state.name == "Idle":
#		$AnimationPlayer.play("land")

	
func _on_descending_kick_started():
# should animation calls come from the State machine or the player?
	if animation_player.has_animation("descending_kick"):
		#animation_player.play("descending_kick")
		$Body/CyberRoninSprites.play("descending_kick")

func _on_descending_kick_impacted():
	pass # not sure what to do here yet.. Probably just ignore it and let the state machine transition to air.

func _on_dash_started():
	if animation_player.has_animation("dash"):
		animation_player.play("dash")
	$Body/CyberRoninSprites.play("dash")
	$Body/SpeedLines.play("default")
	
		
		
func detect_jump_through_platform() -> StaticBody2D:
	var jump_through_platform_detected
	var candidate_bodies = $PlatformDetector.get_overlapping_bodies()
	for candidate in candidate_bodies:
		if candidate.is_in_group("JumpThroughPlatforms") or "jump" in candidate.name.to_lower():
			jump_through_platform_detected = candidate
	return jump_through_platform_detected

func detect_moving_platform() -> AnimatableBody2D:
	var moving_platform_detected
	var candidate_bodies = $PlatformDetector.get_overlapping_bodies()
	for candidate in candidate_bodies:
		if candidate.is_in_group("MovingPlatforms") or candidate is AnimatableBody2D or "moving" in candidate.name.to_lower():
			moving_platform_detected = candidate
	return moving_platform_detected
	
	
