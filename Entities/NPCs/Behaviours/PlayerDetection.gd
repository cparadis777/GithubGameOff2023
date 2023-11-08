extends Node2D

enum States { IDLE, ALERT }
var State = States.IDLE

@onready var PlayerDetector = $RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AlertSprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if State != States.ALERT:
		if PlayerDetector.is_colliding():
			if PlayerDetector.get_collider() == StageManager.current_player:
				_on_player_detected()


func _on_player_detected():
	State = States.ALERT
	$AlertSprite.show()
	$AlertNoise.play()

	await get_tree().create_timer(1.5).timeout
	$AlertSprite.hide()
	

