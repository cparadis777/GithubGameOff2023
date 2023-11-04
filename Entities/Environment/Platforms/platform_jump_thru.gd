# platform which allows the player to jump through on the way up, during jumps,
# also allows the player to pass through going down, when they press the down arrow
# Note: It has to disable a collision bit to allow the player to pass.
# Therefore: It needs 2 collision bits set, one for the player and one for NPCs

extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !has_node("ReactivateTimer"):
		setup_timer()
	$ReactivateTimer.timeout.connect(_on_reactivate_timer_timeout)
	set_collision_layer_value(4, true) # player
	set_collision_layer_value(5, true) # NPCs



func allow_player_to_pass():
	set_collision_mask_value(1, false)
	set_collision_layer_value(4, false)
	$Sprite2D.hide()
	$ReactivateTimer.start()

func setup_timer():
	var timer = Timer.new()
	timer.name = "ReactivateTimer"
	timer.set_wait_time(0.75)
	add_child(timer)
		
func _on_reactivate_timer_timeout():
	set_collision_mask_value(1, true)
	set_collision_layer_value(4, true)
	$Sprite2D.show()
