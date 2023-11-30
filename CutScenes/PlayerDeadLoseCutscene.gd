extends Control


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if $AnimationPlayer.current_animation != "":
			$AnimationPlayer.seek(11.5)


func _on_ai_tutorial_text_finished():
	StageManager.reset_playspace()
