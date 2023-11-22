# Moving platforms.. move between locations in PositionMarkers node.
# we might need to signal the player to keep them moving along with the platform


extends Node2D
# all the normal stuff about enabling and disabling collision bits
# added tween for movement

@export var trigger_node_path : NodePath
var trigger_node

@export var speed = 20.0
#var velocity : Vector2 = Vector2.ZERO

@export var show_piston : bool = true
@export var show_cables : bool = true
@export var autostart: bool = true

@onready var platform = $AnimatableBody2D

var locations : PackedVector2Array = []
var current_destination_index = 1
var distance_tolerance = 5.0
var switch_pressed := false

enum States { MOVING, WAITING }
var State = States.WAITING

var tween : Tween
var tween_duration = 5.0

var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_timer()
	
	await get_tree().create_timer(1.0).timeout
	# wait for global position to be set by instantiator

	hack_workaround_for_starting_position_bug()
	
	
	for locationMarker in $PositionMarkers.get_children():
		locations.push_back(locationMarker.global_position)
	locations.push_back(self.global_position) # make ours go last, so there's no long delay for the tween

	$Piston.visible = show_piston
	$CraneCables.visible = show_cables
	
	#setup_tween()

	if trigger_node_path.is_empty() or autostart:
		start_moving()
	elif get_node(trigger_node_path).get("pressed"):
		start_moving()
	else:
		link(get_node(trigger_node_path))


func hack_workaround_for_starting_position_bug():
	# weird bug in animatable body nodes.. they don't seem to respect their parent's transform on instantiation
	$AnimatableBody2D.global_position = global_position
	# seems to have something to do with sync to physics
	$AnimatableBody2D.sync_to_physics = false



func link(triggerNode):
	trigger_node = triggerNode

func _physics_process(delta):
	$StateLabel.text = States.keys()[State]
	
	if trigger_node != null:
		if State == States.MOVING and (!trigger_node.pressed or !switch_pressed):
			stop_moving()
		elif State == States.WAITING and (trigger_node.pressed or switch_pressed):
			start_moving()

	if State == States.MOVING:
		move_toward_next_location(delta)

func move_toward_next_location(delta):
	# setting position manually should work just as well as tweening, so long as it's in the physics process.
	if State == States.MOVING:
		velocity = platform.global_position.direction_to(locations[current_destination_index]) * speed
		platform.position += velocity * delta
		
		if close_to_target():
			get_next_destination()



func close_to_target():
	return platform.global_position.distance_squared_to(locations[current_destination_index]) < distance_tolerance * distance_tolerance


func get_next_destination():
	current_destination_index = wrapi(current_destination_index + 1, 0, locations.size())


func setup_tween():
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
	for location in locations:
		tween.tween_property(self, "global_position", location, tween_duration)
	tween.pause()
	
	
func start_moving():
	State = States.MOVING
#	if !tween.is_running():
#		tween.play()

func stop_moving():
	State = States.WAITING
#	if tween.is_running():
#		tween.pause()

func _on_switch_toggled(_pressed):
	switch_pressed = !switch_pressed

func allow_player_to_pass():
	platform.set_collision_mask_value(1, false)
	platform.set_collision_layer_value(4, false)
	platform.get_node("Sprite2D").z_index -= 1
	$ReactivateTimer.start()

func setup_timer():
	var timer = Timer.new()
	timer.name = "ReactivateTimer"
	timer.set_wait_time(0.75)
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_reactivate_timer_timeout)

		
func _on_reactivate_timer_timeout():
	platform.set_collision_mask_value(1, true)
	platform.set_collision_layer_value(4, true)
	platform.get_node("Sprite2D").z_index += 1
