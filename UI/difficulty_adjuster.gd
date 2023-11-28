extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$DifficultyLabel.text = "Difficulty: " + Globals.DifficultyScales.keys()[Globals.difficulty]






func change_difficulty(dir):
	$ClickNoise.play()
	Globals.difficulty = (Globals.difficulty + dir)%(Globals.DifficultyScales.keys().size()-1)
	$DifficultyLabel.text = "Difficulty: " + Globals.DifficultyScales.keys()[Globals.difficulty]

func _on_down_button_pressed():
	change_difficulty(-1)
	

func _on_up_button_pressed():
	change_difficulty(+1)


func _on_down_button_mouse_entered():
	$HoverNoise.play()


func _on_up_button_mouse_entered():
	$HoverNoise.play()

