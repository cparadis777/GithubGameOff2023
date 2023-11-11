extends NPC_Behaviour

var decision_timer : Timer
var target_location : Vector2
var melee_range : float = 3.0
var gravity
@export var speed : float = 1.0

var original_doll_scale : Vector2

enum States { WAITING, ACTIVE }
var State = States.WAITING

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	prepare_decision_timer()
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	original_doll_scale = owner.get_node("PaperDoll").scale

func activate():
	State = States.ACTIVE

func is_active():
	return (State == States.ACTIVE)

func prepare_decision_timer():
	decision_timer = Timer.new()
	decision_timer.set_wait_time(1.5)
	add_child(decision_timer)
	decision_timer.timeout.connect(_on_decision_timer_timeout)
	decision_timer.start()


func get_movement_vector(delta):
	var goal_vector = get_goal_vector(delta)
	var gravity_vector = get_gravity_vector(delta)
	return goal_vector + gravity_vector


func get_gravity_vector(delta) -> Vector2:
	var gravity_vector = Vector2.ZERO
	if not owner.is_on_floor():
		gravity_vector.y = owner.velocity.y + (gravity * delta)
	return gravity_vector


func get_goal_vector(_delta) -> Vector2:
	var goal_vector = Vector2.ZERO
	if global_position.distance_squared_to(target_location) > melee_range * melee_range:
		var direction_x = choose_direction()
		goal_vector.x = direction_x * speed
	return goal_vector


func choose_direction():
	var direction_x
	if global_position.x < target_location.x:
		direction_x = 1.0
	else:
		direction_x = -1.0
	return direction_x

func update_goal(): # Decision_timer_timeout
	# find the player, get a path towards them
	if StageManager.current_player != null:
		target_location = StageManager.current_player.global_position
		
func _on_decision_timer_timeout():
	update_goal()
	
