extends Node2D
 
@export_multiline var override_text = "" ## separate "slides" with semi-colons (;)


var messages = [
	"Hello User! 
	Muse AI here: at your service!
	What did you need my help for?",
	"Oh... you're upset at your boss?
	I understand, honestly!
	You get overworked...
	and you're underpaid...",
	"Huh? 
	What's that?
	'Make him taste my finger salad'?",
	"Well...I'm not sure I understand
	what you exactly meant but...
	Whatever you do I'm here to help!",
	"Alright let us 
	get down to business...",
	"You're starting here...",
	"And you want to go there!",
	"Let's use the containers so that
	you can build a path towards 
	accomplishing your objective!",
	 "Use the levers [A] and [D] to move 
	containers left and right!",
	"The [,] button allows you to 
	rotate the containers and [SPACE]
	opens the crane claw!",
	"Why do you want to rotate them?",
	"Well, look over there!",
	"According to my data,
	all container doors don't align.
	So you better place them 
	in the right orientation!",
	"Oh, also, if you ever mess up
	the containers placement
	or orientation...",
	"Just ask me to RESET and I'll try
	to clean up your clutter
	without compromising you...",
	"well...
	
	hopefully!",
	"I'll see you later to
	give you some basic explanation
	on fighting to increase your
	chances of survival!",
	"Good luck, and see 
	you very soon!"
]

var typing_speed = 0.075
var current_message = 0
var display = ""
var current_character = 0
var done_talking = false

signal finished

func _ready():
	if override_text != "":
		messages = override_text.split(";")
	$Label.hide()
	$SpaceBar_UI.hide()
	$Muse_AI.play("idle")
	$AnimationPlayer.play("hello")
	$spawn_timer.start()
#	var current_message = 0
#	var display = ""
#	var current_character = 0
#	done_talking = false

func reset_dialogue():
	current_message = 0
	display = ""
	current_character = 0
	
func start_dialogue():
	show()
	$Text_Bubble.play("default")
	$Muse_AI.play("speaking")
	$Label.show()
	$Text_Bubble.show()
	$next_char.set_wait_time(typing_speed)
	$next_char.start()
	
func _process(_delta):
	if visible and Input.is_action_just_pressed("jump"):
		if current_character < len(messages[current_message]):
			show_entire_message()
		else:
			go_next_message()

func show_entire_message():
	current_character = len(messages[current_message])
	display = messages[current_message]
	$Label.text = display
	
func stop_dialogue():
	finished.emit()
	queue_free()
	
func go_next_message():
	if (current_message == len(messages) - 1):
		$spawn_timer.start()
		done_talking = true
		$AnimationPlayer.play("byebye")
	else:
		
		current_message += 1
		display = ""
		current_character = 0
		$next_char.start()
		$Muse_AI.play("speaking")
		$SpaceBar_UI.hide	()
	
func _on_next_char_timeout():
	if (current_character < len(messages[current_message])) && !done_talking:
		var next_char = messages[current_message][current_character]
		display += next_char
		
		$Label.text = display
		$AI_Speech_SFX.play()
		current_character += 1
		
	else:
		$next_char.stop()
		$Muse_AI.play("idle")
		$SpaceBar_UI.show()
	


func _on_spawn_timer_timeout():
	if !done_talking:
		start_dialogue()
	elif done_talking:
		stop_dialogue()
		
		
