extends Node2D

@export var animation_name:String = ""
@export_multiline var label_text:String = ""
@export var button_texture:Texture
var animation_sequence : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if ";" in animation_name:
		animation_sequence = animation_name.split(";")
		$CyberRoninSprites.animation_finished.connect(_on_animation_finished)
		play_next_in_sequence()
	else:
		$CyberRoninSprites.play(animation_name)
	$Label.text = label_text
	$ButtonSprite.texture = button_texture

func play_next_in_sequence():
	var next_animation = animation_sequence.pop_front()
	if $CyberRoninSprites.sprite_frames.has_animation(next_animation):
		$CyberRoninSprites.play(next_animation)
	
	# loop
	if animation_sequence.size() == 0:
		animation_sequence = animation_name.split(";")


func _on_animation_finished():
	if animation_sequence == null:
		$CyberRoninSprites.play
	else:
		play_next_in_sequence()
