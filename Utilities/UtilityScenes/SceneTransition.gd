extends CanvasLayer

# Scene Transition method from this video: 
# https://www.youtube.com/watch?v=yZQStB6nHuI&ab_channel=TheShaggyDev

func change_scene(scene: PackedScene, wait_seconds: float = 0.0) -> void:
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	if (wait_seconds > 0):
		await get_tree().create_timer(wait_seconds).timeout
	StageManager.change_scene_to(scene)
	$AnimationPlayer.play_backwards("dissolve")
