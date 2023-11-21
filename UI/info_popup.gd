@tool
extends Node2D
@export var next_slide : Node

@export_multiline var info_text : String :
	set(value):
		info_text = value
		$Panel/MarginContainer/VBoxContainer/Label.text = value
	get:
		return info_text

var original_scale : Vector2

func _ready():
	if Engine.is_editor_hint():
		$Panel/MarginContainer/VBoxContainer/Label.text = info_text
	else:
		original_scale = scale
		hide()

func _process(_delta):
	pass
#	if !Engine.is_editor_hint(): # running in game
#		listen_for_next_slide_keys()

func _unhandled_input(event):
	listen_for_next_slide_keys(event)

func listen_for_next_slide_keys(_event):
	if visible:
		var actions_to_hide = ["ui_cancel", "jump", "move_left", "move_right"]
		for action in actions_to_hide:
			if Input.is_action_just_pressed(action):
				hide()
				get_viewport().set_input_as_handled()
				if next_slide != null:
					next_slide.show()


func popup():
	show()
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.33 )
	tween.tween_property(self, "scale", original_scale, 0.33)

func _on_close_panel_button_pressed():
	hide()
	if next_slide:
		next_slide.show()
	
