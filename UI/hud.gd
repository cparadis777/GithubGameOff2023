extends CanvasLayer
var player
var current_container
@onready var minimap = %minimap

# Called when the node enters the scene tree for the first time.
func _ready():
	player = owner
	await owner.ready
	$PauseMenu.hide()
	update_health_display(player.health)

func _process(delta):
	#%SpeedrunTimer.text = str(Time.get_ticks_msec()/1000.0).pad_decimals(2)
	%SpeedrunTimer.text = "Time: " + convertMillisecondsToTimeString(Time.get_ticks_msec())

func convertMillisecondsToTimeString(milliseconds: int) -> String:
	var seconds = milliseconds / 1000
	var minutes = seconds / 60
	seconds %= 60

	return (str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2))

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
	if not $SpamTimer.is_stopped():
		return
		
	if powerupType == Globals.PickupTypes.HEALTH:
		return
	else:
		var new_cutscene = preload("res://CutScenes/powerup_cutscene.tscn").instantiate()
		add_child(new_cutscene)
		new_cutscene.activate(powerupType)
		new_cutscene.position = Vector2.ZERO
		$SpamTimer.start()

func _on_container_entered(containerNode):
	current_container = containerNode
	$Control/HBoxContainer/VBoxContainer/ContainerName.text = containerNode.name

