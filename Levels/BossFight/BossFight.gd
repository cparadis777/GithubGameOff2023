## Final battle scene before game over.
## Player tries to reach and kill the boss, while
## Boss tries to throw Crates down onto the player
##

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and $AnimationPlayer.current_animation != "":
		$AnimationPlayer.seek(15.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
