extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func pop():
	self_modulate.a = 0
	var tween = create_tween()
	var popupHeart = Sprite2D.new()
	popupHeart.texture = texture
	popupHeart.position = Vector2(8, 8)
	popupHeart.name = "TempPopupHeart"
	add_child(popupHeart)
	tween.tween_property(popupHeart, "scale", popupHeart.scale * 2.0, 0.33)
	tween.tween_callback(popupHeart.queue_free)

func reveal():
	show()
	self_modulate.a = 1
	
