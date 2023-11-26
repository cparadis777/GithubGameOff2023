extends PlayerState

signal dead_and_buried


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide()
	dead_and_buried.connect(StageManager._on_player_dead_and_buried)

func enter(_msg := {} ):
	owner.face(1) # face right for tutorial text
	
	var new_tutorial_bot = preload("res://UI/tutorial_ai.tscn").instantiate()
	new_tutorial_bot.override_text = "I'm so sorry you died.\nThat didn't work out.\nLet's rewind a bit..."
	add_child(new_tutorial_bot)
	new_tutorial_bot.global_position = self.global_position + Vector2(-96, 96)
	new_tutorial_bot.z_index = 5
	#$Label.show()
	new_tutorial_bot.finished.connect($Timer.start)
	#$Timer.start()
	



func _on_timer_timeout():
	dead_and_buried.emit()
