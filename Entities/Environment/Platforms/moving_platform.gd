# Moving platforms.. move between locations in PositionMarkers node.
# we might need to signal the player to keep them moving along with the platform


extends "res://Entities/Environment/Platforms/platform_jump_thru.gd"
# all the normal stuff about enabling and disabling collision bits
# added tween for movement

@export var trigger_node_path : NodePath
var trigger_node

@export var speed = 20.0
var velocity : Vector2 = Vector2.ZERO

@export var show_piston : bool = true
@export var show_cables : bool = true
@export var autostart: bool = true

var locations : PackedVector2Array = []
var current_destination_index = 1
var distance_tolerance = 5.0
var switch_pressed := false

enum States { MOVING, WAITING }
var State = States.WAITING

var tween : Tween
var tween_duration = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	await get_tree().create_timer(0.5).timeout
	# wait for global position to be set by instantiator
	
	for locationMarker in $PositionMarkers.get_children():
		locations.push_back(locationMarker.global_position)
	locations.push_back(self.global_position) # make ours go last, so there's no long delay for the tween

	$Piston.visible = show_piston
	$CraneCables.visible = show_cables
	
	setup_tween()

	if trigger_node_path.is_empty():
		start_moving()
	elif get_node(trigger_node_path).get("pressed"):
		start_moving()
	else:
		link(get_node(trigger_node_path))

func link(triggerNode):
	trigger_node = triggerNode

func _physics_process(_delta):
	$StateLabel.text = States.keys()[State]
	
	if trigger_node != null:
		if State == States.MOVING and (!trigger_node.pressed or !switch_pressed):
			stop_moving()
		elif State == States.WAITING and (trigger_node.pressed or switch_pressed):
			start_moving()

func deprecated_alternate_movement(delta):
	# setting position manually should work just as well as tweening, so long as it's in the physics process.
	if State == States.MOVING:
		velocity = global_position.direction_to(locations[current_destination_index]) * speed
		global_position += velocity * delta
		if close_to_target():
			get_next_destination()



func close_to_target():
	return global_position.distance_squared_to(locations[current_destination_index]) < distance_tolerance * distance_tolerance


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
	if !tween.is_running():
		tween.play()

func stop_moving():
	State = States.WAITING
	if tween.is_running():
		tween.pause()

func _on_switch_toggled():
	switch_pressed = !switch_pressed

