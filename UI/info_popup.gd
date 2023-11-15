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
	if !Engine.is_editor_hint(): # running in game
		if visible:
			if Input.is_action_just_pressed("ui_cancel"):
				hide()


func popup():
	show()
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * 1.2, 0.33 )
	tween.tween_property(self, "scale", original_scale, 0.33)

func _on_close_panel_button_pressed():
	hide()
	if next_slide:
		next_slide.show()
	
