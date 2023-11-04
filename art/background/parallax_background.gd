extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Clouds.motion_offset.x -= 20 * delta
	$Steam.motion_offset.x -= 6 * delta
