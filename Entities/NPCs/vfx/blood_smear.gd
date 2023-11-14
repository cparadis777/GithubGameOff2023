extends Node2D

var original_scale
@export var duration = 1.5 # seconds
@export var blood_sprite : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if !blood_sprite:
		blood_sprite = $Polygon2D
	original_scale = blood_sprite.scale
	blood_sprite.hide()
	blood_sprite.scale.y = 0.01
		

func activate():
	blood_sprite.show()
	var tween = create_tween()
	tween.tween_property(blood_sprite, "scale", original_scale, duration)
