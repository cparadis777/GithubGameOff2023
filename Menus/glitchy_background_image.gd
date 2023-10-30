
# grabbed a shader from https://godotshaders.com/shader/glitch-effect-shader/
extends Control


@export var high_spec_texture : Texture2D
@export var low_spec_texture : Texture2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CyberpunkBGGlitch.hide()
	activate_glitch_effects()
	_on_graphics_toggled()


func activate_glitch_effects():
	$GlitchTimer.timeout.connect(_on_glitch_timer_timeout)
	$GlitchNoise.finished.connect(_on_noise_finished)
	#$GlitchTimer.start()


func _on_glitch_timer_timeout():
	if Globals.user_prefs["graphics"] == Globals.Graphics.HIGH:
		$CyberpunkBGGlitch.show()
		$GlitchNoise.play()
	else:
		print("graphics = " + str(Globals.user_prefs["graphics"]))
	


func _on_noise_finished():
	$CyberpunkBGGlitch.hide()
	$GlitchTimer.set_wait_time(randf_range(3.0, 10.0))
	$GlitchTimer.start()

func _on_graphics_toggled():
	match Globals.user_prefs["graphics"]:
		Globals.Graphics.LOW:
			$CyberpunkBG.texture = low_spec_texture
		Globals.Graphics.HIGH:
			$CyberpunkBG.texture = high_spec_texture
			if $GlitchTimer.is_stopped():
				$GlitchTimer.start()

