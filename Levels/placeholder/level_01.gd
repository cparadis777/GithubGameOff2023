extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	StageManager.current_level = self


func get_camera_target() -> Vector2:
	if has_node("CameraTarget"):
		return $CameraTarget.global_position
	else:
		return Vector2(0, -113)
		
	
		
