extends Sprite2D

enum States { INITIALIZING, READY, MOVING }
var State = States.INITIALIZING



# Called when the node enters the scene tree for the first time.
func _ready():
	print($VisibleOnScreenNotifier2D.get_relative_transform_to_parent(self))
	await get_tree().create_timer(0.1).timeout
	State = States.READY



func _on_visible_on_screen_enabler_2d_screen_exited():
	if State == States.READY:
		# move the ground image  in the direction of the camera, twice it's size.
		
		var distance = self.get_rect().size.x * 2.0
		var direction = self.global_position.direction_to(get_viewport().get_camera_2d().global_position)
		direction.y = 0

		State = States.MOVING
		var tween = create_tween()
		#tween.tween_property(self, "position", position + Vector2(0, 64), 0.5)
		tween.tween_property(self, "position", position + direction * distance, 0.5)
		#tween.tween_property(self, "position", position + Vector2(0, -64), 0.5)
		await tween.finished
		State = States.READY

