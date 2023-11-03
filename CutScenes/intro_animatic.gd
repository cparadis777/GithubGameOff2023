extends Node2D

@export var starting_animation = "intro_animatic"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		$AnimationPlayer.play(starting_animation)
