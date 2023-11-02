extends CharacterBody2D


@export var SPEED = 100.0
@export var JUMP_VELOCITY = -250.0

@onready var camera = $Camera2D
@onready var hud = $HUD

enum States { IDLE, RUNNING, JUMPING, ATTACKING }
var State = States.IDLE



signal hit




# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _enter_tree():
	StageManager.current_player = self


func _ready():
	$Body/Actions/Kick/HurtBox/CollisionShape2D.disabled = true
	$Body/Actions/Punch/HurtBox/CollisionShape2D.disabled = true
	$ReferenceRunCycle.hide()
	play_idle_animation()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


		
	move_and_slide()
	
func _input(_event):
	if Input.is_action_just_pressed("shoot"):
		spawn_bullet_toward_mouse()
	elif Input.is_action_just_pressed("debug"):
		initiate_debugging_protocol()
	elif Input.is_action_just_pressed("kick"):
		kick()
	elif Input.is_action_just_pressed("punch"):
		punch()
	elif Input.is_action_just_pressed("move_left"):
		play_run_animation()
		$Body.scale.x = -1
	elif Input.is_action_just_pressed("move_right"):
		play_run_animation()
		$Body.scale.x = 1
	
	check_for_idle()
	
func check_for_idle():
	var movement_actions = [ "move_left", "move_right"]
	for action in movement_actions:
		if Input.is_action_just_released(action):
			var any_action_key_pressed = false
			var blockingActions = [ "move_left", "move_right", "jump", "kick" ]
			for blockingAction in blockingActions:
				if Input.is_action_pressed(blockingAction):
					any_action_key_pressed = true
			if !any_action_key_pressed:
				State == States.IDLE
				play_idle_animation()
		
func play_run_animation():
	if State in [ States.RUNNING, States.IDLE ]:
		if $AnimationPlayer.current_animation != "run":
			$AnimationPlayer.play("run")
			
func play_idle_animation():
	if State in [ States.IDLE ]:
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")

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

func punch():
	if State in [ States.IDLE, States.RUNNING ]:
		if $AnimationPlayer.current_animation != "punch":
			State = States.ATTACKING
			$AnimationPlayer.play("punch")
		
func kick():
	if State in [ States.IDLE, States.RUNNING ]:

		if $AnimationPlayer.current_animation != "kick":
			State = States.ATTACKING
			$AnimationPlayer.play("kick")


func hurt(body):
	var damage = 10.0
	var impactVector = body.global_position - self.global_position
	var knockback = true
	var damageType = Globals.DamageTypes.IMPACT

	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
	hit.emit(damage, impactVector, damageType, knockback)
	if hit.is_connected(body._on_hit):
		hit.disconnect(body._on_hit)


func _on_hurt_box_body_entered(body):
	# kick or punch
	if body.is_in_group("Enemies"):
		hurt(body)
		
			


func _on_animation_player_animation_finished(anim_name):
	if State == States.ATTACKING and anim_name in [ "punch", "kick" ]:
		if velocity.length_squared() > 0.5:
			State = States.RUNNING
			play_run_animation()
		else:
			State = States.IDLE
			play_idle_animation()
