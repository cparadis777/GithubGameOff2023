# grabbed a shader from https://godotshaders.com/shader/glitch-effect-shader/
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$CyberpunkBGGlitch.hide()
	$GlitchNoise.finished.connect(_on_noise_finished)


func _on_timer_timeout():
	$CyberpunkBGGlitch.show()
	$GlitchNoise.play()
	
func _on_noise_finished():
	$CyberpunkBGGlitch.hide()
	$Timer.set_wait_time(randf_range(3.0, 10.0))
	$Timer.start()
	
