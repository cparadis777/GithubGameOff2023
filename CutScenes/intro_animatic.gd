extends Node2D

@export var starting_animation = "intro_animatic"
var started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if not started:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			$AnimationPlayer.play(starting_animation)
			started = true
	if event.is_action_pressed("ui_cancel"):
		$AnimationPlayer.seek(14.9, true)


func _on_animation_player_animation_finished(anim_name):
	get_node("Slide4-TitleMenu/PlatformerStartButton").grab_focus()
	
