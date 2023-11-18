
extends Node2D

var charge_level : int = 0
var max_charge : int = 2
var temp_audio_streams : AudioStreamRandomizer
var temp_audio_stream_player : AudioStreamPlayer2D

signal finished()

func start():
	charge_level = 0
	$Duration_Per_Level.start()

	temp_audio_streams = $ChargeAudioSequence.stream.duplicate()
	temp_audio_stream_player = AudioStreamPlayer2D.new()
	temp_audio_stream_player.stream = temp_audio_streams
	add_child(temp_audio_stream_player)
	temp_audio_stream_player.play()
	

func play():
	start()


func stop():
	$Duration_Per_Level.stop()
	if is_instance_valid(temp_audio_stream_player):
		temp_audio_stream_player.queue_free()
	charge_level = 0

func _on_duration_per_level_timeout():
	if charge_level < max_charge:
		temp_audio_stream_player.stop()
		temp_audio_stream_player.play()
		$Duration_Per_Level.start()
		charge_level += 1
	
