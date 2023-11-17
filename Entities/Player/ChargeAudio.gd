
extends Node2D

var charge_level : int = 0
var max_charge : int = 2

signal finished()

func start():
	charge_level = 0
	$ChargeAudioSequence.play()
	$Duration_Per_Level.start()

func play():
	start()


func stop():
	$ChargeAudioSequence.stop()


func _on_duration_per_level_timeout():
	if charge_level < max_charge:
		$ChargeAudioSequence.stop()
		$ChargeAudioSequence.play()
		$Duration_Per_Level.start()
		charge_level += 1
	
