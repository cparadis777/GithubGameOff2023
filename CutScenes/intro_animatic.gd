extends Node2D

@export var starting_animation = "intro_animatic"
var started = false
@onready var start_button = %ButtonPanel/TutorialButton
# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_track("MainMenuTheme")
	connect_button_audio()
	
func connect_button_audio():
	for button in %ButtonPanel.get_children():
		if button is Button or button is TextureButton:
			button.mouse_entered.connect($Audio/HoverNoise.play)
			button.pressed.connect($Audio/ClickNoise.play)
			button.focus_entered.connect($Audio/HoverNoise.play)

	

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
	
