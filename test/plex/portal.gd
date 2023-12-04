## works like one-way teleporter
## a marker identifies the destination

extends Node2D
var body_in_transit

var directions = {
	"UP": Vector2.UP,
	"RIGHT": Vector2.RIGHT,
	"DOWN":Vector2.DOWN,
	"LEFT": Vector2.LEFT,
}     

var distance = 196
@export var linked_portal : Node
@export var tween_duration : float = 1.25
@export var locked = false:
	set(value):
		locked = value
		if name == "RIGHT" or name == "LEFT":
			if value:
				$DoorSprite.frame = 0
			else:
				$DoorSprite.frame = 17


func _ready():
	if directions.has(name):
		$Destination.global_position = global_position + directions[name] * distance
	
	if name == "RIGHT" or name == "LEFT":
		if !locked:
			$DoorSprite.frame = 17

	if has_node("InteractLabel"):
		$InteractLabel.hide()

	await get_tree().create_timer(0.5).timeout
	link_nearby_door()

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_present():
		interact()
		get_viewport().set_input_as_handled()

func link_nearby_door():
	if has_node("paired_door_detector"):
		var possible_matching_doors = $paired_door_detector.get_overlapping_areas()
		for candidate in possible_matching_doors:
			if candidate.get_parent().has_method("open_door") and candidate.get_parent() != self:
				linked_portal = candidate.owner
				



func _on_delay_opening_timer_timeout():
	# player still present after a short interval.
	if player_present() and not live_enemies_present():
		open_door()
		if linked_portal != null and is_instance_valid(linked_portal) and linked_portal.has_method("open_door"):
			linked_portal.open_door()
		await get_tree().create_timer(0.8).timeout
		var body_to_transport = player_present()
		if body_to_transport != null:
			transport_player(body_to_transport)

func live_enemies_present():
	var live_enemies = false
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Enemies") and body.State != body.States.DEAD:
			live_enemies = true
	return live_enemies

func player_present():
	var player_body = null
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Player"):
			if body.state_machine.state.name not in ["InTransit", "Dying", "Dead", "Paused"]:
				player_body = body
		
	return player_body


func open_door():
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("open")


func transport_player(body):
	body._on_door_entered()
	var tween = create_tween()
	tween.tween_property(body, "global_position", $Destination.global_position, tween_duration)
	body_in_transit = body
	if (linked_portal):
		linked_portal.locked = false
	tween.finished.connect(_on_tween_finished)


func close_door():
	if has_node("AnimationPlayer"):
		if (locked):
			$AnimationPlayer.play("close")
		else:
			$AnimationPlayer.play("close_unlocked")


func _on_tween_finished():
	if body_in_transit != null and is_instance_valid(body_in_transit):
		body_in_transit._on_door_exited()
		body_in_transit = null
		close_door()
		if linked_portal != null and is_instance_valid(linked_portal) and linked_portal.has_method("close_door"):
			linked_portal.close_door()

func interact():
	if !locked:
		$Area2D/DelayOpeningTimer.stop()
		_on_delay_opening_timer_timeout()
	else:
		if $AnimationPlayer.has_animation("locked"):
			$AnimationPlayer.play("locked")
		
func _on_area_2d_body_entered(body):
	
	if "player" in body.name.to_lower() and body.state_machine.state.name != "InTransit" and !locked:
		if has_node("InteractLabel"):
			$InteractLabel.show()
		#$Area2D/DelayOpeningTimer.start()


func _on_area_2d_body_exited(body):
	if "player" in body.name.to_lower() and body.state_machine.state.name != "InTransit" and !locked:
		if has_node("InteractLabel"):
			$InteractLabel.hide()
