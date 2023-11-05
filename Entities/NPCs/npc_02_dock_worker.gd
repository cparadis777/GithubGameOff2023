extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var original_doll_scale : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	$Behaviours/Movement/WalkTowardPlayer.activate()
	original_doll_scale = $PaperDoll.scale

func _physics_process(delta):
	for movement in $Behaviours/Movement.get_children():
		if movement.is_active():
			velocity += movement.get_movement_vector(delta)
	update_animations()
	move_and_slide()

func update_animations():
	$PaperDoll.scale.x = signf(velocity.x) * original_doll_scale.x
	if abs(velocity.x) > 0 and $AnimationPlayer.current_animation != "walk":
		$AnimationPlayer.play("walk")


