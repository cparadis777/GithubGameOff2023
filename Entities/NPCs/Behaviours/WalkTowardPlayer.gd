extends NPC_Behaviour

var decision_timer : Timer
var target_location : Vector2
var melee_range : float = 20.0
var gravity
@export var speed : float = 15.0

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	print("npc behaviour: owner = " + owner.name)
	prepare_decision_timer()
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func prepare_decision_timer():
	decision_timer = Timer.new()
	decision_timer.set_wait_time(1.5)
	add_child(decision_timer)
	decision_timer.timeout.connect(update_goal)
	decision_timer.start()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_toward_goal(delta)
	apply_gravity(delta)
	owner.move_and_slide()

func apply_gravity(delta):
	if not owner.is_on_floor():
		owner.velocity.y += gravity * delta
	else:
		owner.velocity.y = 0

func move_toward_goal(delta):
	if global_position.distance_squared_to(target_location) > melee_range * melee_range:
		var direction_x
		if global_position.x < target_location.x:
			direction_x = 1
		else:
			direction_x = -1
		owner.velocity.x = direction_x * speed * delta

func update_goal():
	# find the player, get a path towards them
	if StageManager.current_player != null:
		target_location = StageManager.current_player.global_position
		
