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
	var low_hz = 2000
	var high_hz = 20000
	var amplitude = analyzer.get_magnitude_for_frequency_range(low_hz, high_hz, analyzer.MAGNITUDE_MAX).x # x = left ear
	var magnitude = 600.0
	material.set_shader_parameter("magnitude", amplitude * magnitude)
