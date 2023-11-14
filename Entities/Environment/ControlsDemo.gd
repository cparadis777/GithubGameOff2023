extends Node2D

@export var animation_name:String = ""
@export_multiline var label_text:String = ""
@export var button_texture:Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	$CyberRoninSprites.play(animation_name)
	$Label.text = label_text
	$ButtonSprite.texture = button_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
