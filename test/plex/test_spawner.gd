extends Node2D

var location : Vector2 = Vector2.ZERO
var room_num : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	#spawn a room
	var new_room_metadata = ContainerCatalog.get_children().pick_random()
	var new_room = new_room_metadata.packed_scene.instantiate()
	print("name before entering tree: " , new_room.name)
	new_room.name = str(room_num) + "_" + new_room.name
	add_child(new_room)
	print("name after entering tree: ", new_room.name)
	new_room.global_position = location
	if new_room.has_node("Exterior"):
		new_room.get_node("Exterior").hide()
	location += Vector2.UP * 420
	room_num += 1
