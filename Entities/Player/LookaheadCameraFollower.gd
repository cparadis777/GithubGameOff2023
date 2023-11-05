extends Node2D

var player
var camera
var lookahead_vector = Vector2(96, 96)
var lookahead_speed = 1.5
var original_offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	player = owner
	camera = get_node("Camera2D")
	original_offset = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	#lookahead(delta)


func lookahead(delta):
	if abs(player.velocity.x) > 0.05:
		var dir = sign(player.velocity.x)
		position.x = floor(lerpf(position.x, dir * lookahead_vector.x, 0.8))
	else:
		position.x = floor(lerpf(position.x, 0, 0.75 * lookahead_speed * delta))

	# not sure how to handle vertical lookahead yet..
	# player would want to see up or down _before_ they jump.
	# if we can get a distance from the floor, maybe...
	
#	if StageManager.current_level.has_method("get_camera_target"):
#		var middle_of_room = StageManager.current_level.get_camera_target()
#		var playerPos = player.global_position
#		if playerPos.y > middle_of_room.y: # player at bottom of stage
#			position.y = floor(lerpf(position.y, original_offset.y - lookahead_vector.y, lookahead_speed * delta))
#		elif playerPos.y < middle_of_room.y: # player at top of stage
#			position.y = floor(lerpf(position.y, original_offset.y + lookahead_vector.y, lookahead_speed * delta))
#
#	else:
#		printerr(StageManager.curent_level.name + ": (config error) Fighting Levels should have a method called get_camera_target which returns the location of the middle of the room in global_coordinates.")
