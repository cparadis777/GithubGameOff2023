extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_timer_timeout():
	var material : ShaderMaterial = $Plane3D.get_active_material(0)
	#var shader : Shader = material.shader
	var busID = AudioServer.get_bus_index("Master")
	var spectrumAnalyzerEffectID = 0
	var channelID = 0
	var analyzer : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(busID, spectrumAnalyzerEffectID, channelID )
	var drums = [ 20, 800 ] # rough frequency range
	var _horns = [ 800, 20000] # rough frequency range
	var instrument = drums
	var amplitude = analyzer.get_magnitude_for_frequency_range(instrument[0], instrument[1], analyzer.MAGNITUDE_MAX).x # x = left ear
	var magnitude = 200.0
	material.set_shader_parameter("magnitude", amplitude * magnitude)
