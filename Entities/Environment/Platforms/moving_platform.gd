# Moving platforms.. move between locations in PositionMarkers node.
# we might need to signal the player to keep them moving along with the platform


extends "res://Entities/Environment/Platforms/platform_jump_thru.gd"
# all the normal stuff about enabling and disabling collision bits
# added tween for movement

@export var trigger_node_path : NodePath
var trigger_node

@export var speed = 20.0
var velocity : Vector2 = Vector2.ZERO

var locations : PackedVector2Array = []
var current_destination_index = 0
var distance_tolerance = 5.0

enum States { MOVING, WAITING }
var State = States.WAITING

var tween : Tween
var tween_duration = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	for locationMarker in $PositionMarkers.get_children():
		locations.push_back(locationMarker.global_position)

	get_next_destination() # skip the first one
	setup_tween()

	if trigger_node_path.is_empty():
		start_moving()
	elif get_node(trigger_node_path).get("pressed"):
		start_moving()

func link(triggerNode):
	trigger_node = triggerNode

func _physics_process(delta):
	$StateLabel.text = States.keys()[State]
	
	if trigger_node != null:
		if State == States.MOVING and !trigger_node.pressed:
			stop_moving()
		elif State == States.WAITING and trigger_node.pressed:
			start_moving()
	
#	if State == States.MOVING:
#		velocity = global_position.direction_to(locations[current_destination_index]) * speed
#		global_position += velocity * delta
#		if close_to_target():
#			get_next_destination()

	if tween != null:
		if State == States.WAITING and tween.is_running():
			tween.pause()
		elif State == States.MOVING and !tween.is_running():
			tween.play()

func close_to_target():
	return global_position.distance_squared_to(locations[current_destination_index]) < distance_tolerance * distance_tolerance


func get_next_destination():
	current_destination_index = wrapi(current_destination_index + 1, 0, locations.size())


func setup_tween():
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
	for i in range(locations.size()):
		tween.tween_property(self, "global_position", locations[i], tween_duration)
	tween.pause()
	
	
func start_moving():
	State = States.MOVING

func stop_moving():
	State = States.WAITING
