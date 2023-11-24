extends Area2D

enum States { IDLE, MAGNETIZED, PICKED }
var State = States.IDLE
var velocity : Vector2
var target : CharacterBody2D
var move_speed : float = 100.0

var PickupTypes = Globals.PickupTypes
@export var pickup_type : Globals.PickupTypes = Globals.PickupTypes.HEALTH

signal picked_up(pickup_type)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func magnetize():
	State = States.MAGNETIZED
	var tween = create_tween()
	var original_scale = scale
	tween.tween_property(self, "scale", self.scale * 1.5, 0.33)
	tween.tween_property(self, "scale", original_scale, 0.33)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State == States.MAGNETIZED:
		global_position += velocity * delta
		chase_target()

func chase_target():
	velocity = global_position.direction_to(target.global_position) * move_speed


func _on_magnet_area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		magnetize()
		chase_target()

func pickup(body):
	if not picked_up.is_connected(body._pickable_picked_up):
		picked_up.connect(body._pickable_picked_up)
	picked_up.emit(pickup_type)
	pop()

func pop():
	$PickupNoise.play()
	var tween = create_tween()
	tween.tween_property(self, "scale", self.scale * 1.5, 0.25)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween.finished
	queue_free()

	


func _on_body_entered(body):
	if body.is_in_group("Player"):
		pickup(body)
