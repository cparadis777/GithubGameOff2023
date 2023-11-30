extends SubViewportContainer
@onready var viewport = $SubViewport

var scale_differential = 30.0
var offset = Vector2(-32,32)

func _ready():
	pass

	await get_tree().create_timer(1.5).timeout
	create_map()
	$SubViewport/MapRefreshTimer.start()

func create_map():
	var playspace
	playspace = get_tree().get_first_node_in_group("GeneratedPlayspace")
	if playspace == null:
		playspace = get_tree().get_root().find_child("FightLevel")
	if playspace == null:
		playspace = get_tree().get_root().find_child("GeneratedPlayspace")
	
	var container_nodes : Array = []
	if playspace != null and playspace.has_node("ContainerGrid"):
		container_nodes = playspace.get_node("ContainerGrid").get_children()

		for slot in container_nodes:
			if slot.get_child_count() > 0:
				var container = slot.get_child(0)
				if container.get("container_exit_flags") != null: # it's a container
					var new_container_sprite = $SubViewport/ContainerSpriteTemplates/ContainerSpriteTemplate.duplicate()
					$SubViewport/Rooms.add_child(new_container_sprite)
					new_container_sprite.position = container.global_position / scale_differential + offset
					new_container_sprite.frame = container.type
					new_container_sprite.visible = true
					#new_container_sprite.scale = Vector2.ONE * 1.25
		%Camera2D.zoom = Vector2(0.5, 0.5)
	

func update_map():
	# move the player location around
	$SubViewport/RobotHead.position = StageManager.current_player.global_position / scale_differential + offset

func _on_timer_timeout():
	update_map()
	
