extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	self.stop_all_tracks()
	#self.play_track("Track1")




func stop_all_tracks() -> void:
	for child in self.get_children():
		child.stop()

func play_track(track_name:String) -> void:
	self.stop_all_tracks()
	get_node(track_name).play()
