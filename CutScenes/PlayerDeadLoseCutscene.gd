extends Control

func _ready():
	play_music()
	
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if $AnimationPlayer.current_animation != "":
			$AnimationPlayer.seek(8.5)


func _on_ai_tutorial_text_finished():
	StageManager.reset_playspace()

func play_music():
	AudioManager.play_track("CreditsTheme")
