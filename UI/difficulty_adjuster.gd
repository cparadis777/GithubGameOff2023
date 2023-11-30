extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.set_difficulty_based_on_weight()
	$DifficultyLabel.text = "Difficulty: " + Globals.DifficultyScales.keys()[Globals.difficulty]






func increment_difficulty(dir):
	$ClickNoise.play()
	Globals.difficulty = (Globals.difficulty + dir)%(Globals.DifficultyScales.keys().size()-1)
	$DifficultyLabel.text = "Difficulty: " + Globals.DifficultyScales.keys()[Globals.difficulty]

func _on_down_button_pressed():
	increment_difficulty(-1)
	

func _on_up_button_pressed():
	increment_difficulty(+1)


func _on_down_button_mouse_entered():
	$HoverNoise.play()


func _on_up_button_mouse_entered():
	$HoverNoise.play()

func update():
	$DifficultyLabel.text = "Difficulty: " + Globals.DifficultyScales.keys()[Globals.difficulty]
