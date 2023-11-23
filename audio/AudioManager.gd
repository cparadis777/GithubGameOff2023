extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	self.stop_all_tracks()
	#self.play_track("MainMenuTheme")
	#self.play_track("CreditsTheme")
	#self.play_track("FightingTheme")
	#self.play_track("CraneLevelTheme")
	#self.play_track("CraneLevelAmbiance")




func stop_all_tracks() -> void:
	for child in self.get_children():
		child.stop()

func play_track(track_name:String) -> void:
	self.stop_all_tracks()
	get_node(track_name).play()
