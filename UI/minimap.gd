extends SubViewportContainer
@onready var viewport = $SubViewport

var scale_differential = 20.0
var offset = Vector2(-32,32)

func _ready():
	pass

	await get_tree().create_timer(1.5).timeout
	create_map()


func create_map():

	for container in get_tree().get_root().get_node("GeneratedPlayspace/ContainerGrid").get_children():
		if container.get("container_exit_flags") != null: # it's a container
			var new_container_sprite = $SubViewport/ContainerSpriteTemplates/ContainerSpriteTemplate.duplicate()
			$SubViewport/Rooms.add_child(new_container_sprite)
			new_container_sprite.position = container.global_position / scale_differential + offset
			new_container_sprite.frame = container.type
			new_container_sprite.visible = true
			
	$SubViewport/Camera2D.zoom = Vector2(0.5, 0.5)
	

func update_map():
	# move the player location around
	$SubViewport/RobotHead.position = StageManager.current_player.global_position / scale_differential + offset

func _on_timer_timeout():
	update_map()
	
