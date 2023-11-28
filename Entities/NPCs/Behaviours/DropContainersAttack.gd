extends NPC_Behaviour


@export var enabled: bool = true
@export var container_scene : PackedScene = preload("res://Entities/Projectiles/bullet_tossed_shipping_container.tscn")

enum States { INACTIVE, IDLE, MOVING, RELOADING }
var State : States = States.INACTIVE
var speed : float = 250.0
var direction : int = 1
var original_position : Vector2
var max_distance : float = 512
var last_drop_position : Vector2

func _ready():
	original_position = global_position


func _process(delta):
	if State == States.INACTIVE:
		return
	elif State == States.MOVING:
		position.x += direction * speed * delta
		maybe_reverse_direction(delta)
	if global_position.distance_squared_to(original_position) > max_distance * max_distance:
		direction = sign(original_position.x - global_position.x)

	$Label.text = States.keys()[State]

func spawn_crate():
	var crate_scene = container_scene.instantiate()
	add_sibling(crate_scene)
	crate_scene.global_position = $Jaws/JawsSprite/Muzzle.global_position
	last_drop_position = global_position
	

func maybe_reverse_direction(delta):
	var chance_per_second = 0.15
	if randf() < chance_per_second * delta:
		direction *= -1
	


func activate():
	if enabled:
		State = States.IDLE

func start():
	if enabled:
		State = States.MOVING
		$MoveTimer.start()

func stop():
	if enabled:
		State = States.IDLE
		$MoveTimer.stop()
		$ReloadTimer.stop()




func _on_reload_timer_timeout():
	$MoveTimer.start()
	State = States.MOVING


func clear_to_drop():
	var max_jitter_sq_at_same_location = 48.0 * 48
	var min_distance_sq_for_new_location = 300.0 * 300
	if last_drop_position == null:
		return true
	var dist_sq = global_position.distance_squared_to(last_drop_position)
	if dist_sq < max_jitter_sq_at_same_location or dist_sq > min_distance_sq_for_new_location:
		return true
	else:
		return false

func _on_move_timer_timeout():
	if randf() < 0.67 and clear_to_drop():
		spawn_crate()
	$ReloadTimer.start()
	State = States.RELOADING
