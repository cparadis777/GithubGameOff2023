extends Node2D

var location : Vector2 = Vector2.ZERO
var room_num : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#var num_available = ContainerCatalog.get_children().size()
	var containers : Array = []
	for i in range(2):
		containers.append_array(ContainerCatalog.get_children())
	
	containers.shuffle()
	
	for i in range(containers.size()):
		spawn_container(containers.pop_back())

	AudioManager.play_track("FightingTheme")

func spawn_container(container_metadata):
	#spawn a room
	var new_room_metadata = container_metadata
	var new_room = new_room_metadata.packed_scene.instantiate()
	new_room.name = str(room_num) + "_" + new_room.name
	if room_num == 0:
		new_room.container_exit_flags = 4 # up only
	else:
		new_room.container_exit_flags = 12 # up and down
	
	add_child(new_room)
	new_room.global_position = location
	if new_room.has_node("Exterior"):
		new_room.get_node("Exterior").hide()
	location += Vector2.UP * 420
	room_num += 1
