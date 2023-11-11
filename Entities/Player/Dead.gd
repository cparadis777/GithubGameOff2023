extends PlayerState

signal dead_and_buried


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide()
	dead_and_buried.connect(StageManager._on_player_dead_and_buried)

func enter(_msg := {} ):
	$Label.show()
	$Timer.start()
	



func _on_timer_timeout():
	dead_and_buried.emit()
