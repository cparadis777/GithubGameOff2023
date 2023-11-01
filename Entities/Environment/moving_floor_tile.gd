extends Sprite2D

enum States { INITIALIZING, READY, MOVING }
var State = States.INITIALIZING



# Called when the node enters the scene tree for the first time.
func _ready():
	#print($VisibleOnScreenNotifier2D.get_relative_transform_to_parent(self))
	await get_tree().create_timer(0.1).timeout
	State = States.READY



func _on_visible_on_screen_enabler_2d_screen_exited():
	if State == States.READY:
		# move the ground image  in the direction of the camera, twice it's size.

		var tile_count = get_parent().get_child_count()
		var distance = self.get_rect().size.x * float(tile_count)
		var camera = get_viewport().get_camera_2d()
		
		var direction
		if camera.global_position.x > self.global_position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		State = States.MOVING
		var tween = create_tween()
		#tween.tween_property(self, "position", position + Vector2(0, 64), 0.5)
		tween.tween_property(self, "position", position + direction * distance, 0.5)
		#tween.tween_property(self, "position", position + Vector2(0, -64), 0.5)
		await tween.finished
		State = States.READY

