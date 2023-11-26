extends Node2D

@export var starting_animation = "intro_animatic"
var started = false
@onready var start_button = get_node("Slide4-TitleMenu/Control-Panel/TutorialButton")
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_track("MainMenuTheme")
	

func _input(event):
	if not started:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			$AnimationPlayer.play(starting_animation)
			started = true
	if event.is_action_pressed("pause"):
		$AnimationPlayer.seek(14.9, true)
		start_button.grab_focus()


func _on_animation_player_animation_finished(_anim_name):
	pass
	#find_node("PlatformerStartButton").grab_focus()
	
