extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = false
	await get_tree().create_timer(3).timeout
	set_custom_viewport(StageManager.current_player.hud.minimap.viewport)
	print(get_viewport().name)
	enabled = true
	make_current()

