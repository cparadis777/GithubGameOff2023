extends CharacterBody2D


@export var SPEED = 100.0
@export var JUMP_VELOCITY = -175.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


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
	# use an animation node and hurtboxes later.
	$AnimationPlayer.play("punch")
	
func kick():
	$AnimationPlayer.play("kick")
	
