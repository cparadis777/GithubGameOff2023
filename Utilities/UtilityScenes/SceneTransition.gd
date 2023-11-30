extends CanvasLayer

# Scene Transition method from this video: 
# https://www.youtube.com/watch?v=yZQStB6nHuI&ab_channel=TheShaggyDev
signal finished

func change_scene(scene: PackedScene, anim_length: float = 0.5, hold: float = 0.0) -> void:
	$AnimationPlayer.get_animation("dissolve").length = anim_length
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	if (hold > 0):
		await get_tree().create_timer(hold).timeout
	StageManager.change_scene_to(scene)
	$AnimationPlayer.play("resolve")
	


func fade_out():
	$AnimationPlayer.play("drop_down")
	
func fade_in():
	$AnimationPlayer.play("drop_out")
	

func _on_animation_player_animation_finished(anim_name):
	finished.emit()
