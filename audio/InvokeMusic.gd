extends Node

@export var audio_track: String = ""


func _ready():
	if audio_track != null:
		AudioManager.play_track(audio_track)

