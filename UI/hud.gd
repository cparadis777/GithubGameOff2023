extends CanvasLayer
var player
@onready var minimap = %minimap

# Called when the node enters the scene tree for the first time.
func _ready():
	player = owner
	await owner.ready
	$PauseMenu.hide()
	update_health_display(player.health)
	

func update_health_display(health_remaining : float):
	var heart_value = 10.0
	#var hearts_available = $Control/HBoxContainer/HealthIcons.get_child_count()
	for heart in $Control/HBoxContainer/HealthIcons.get_children():
		if (heart.get_index()+1)*heart_value <= health_remaining:
			heart.reveal()
		else:
			if heart.visible and heart.self_modulate.a == 1:
				heart.pop()
			#heart.hide()



func _on_player_hit(_attackPacket):
	update_health_display(player.health)
	if _attackPacket.damage > 5:
		$AnimationPlayer.play("big_hit")
	
func _on_player_picked_up_health():
	update_health_display(player.health)
	
func _on_player_picked_up_powerup(powerupType : Globals.PickupTypes):
	if powerupType == Globals.PickupTypes.HEALTH:
		return
	else:
		var new_cutscene = preload("res://CutScenes/powerup_cutscene.tscn").instantiate()
		add_child(new_cutscene)
		new_cutscene.activate(powerupType)
		new_cutscene.position = Vector2.ZERO
	



