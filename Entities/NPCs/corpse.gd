extends Node2D

var velocity : Vector2 = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func activate():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if visible:
		apply_gravity(delta)
	position += velocity * delta
	
func apply_gravity(delta):
	if $PlatformDetector.get_overlapping_bodies().size() == 0:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
