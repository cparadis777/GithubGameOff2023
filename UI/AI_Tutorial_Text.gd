extends Node
 
var messages = [
	"Hello User! 
	Muse AI here: at your service!
	What did you need my help for?",
	"Oh... you're upset at your boss?
	I understand, honestly!
	You get overworked...
	and you're underpaid...",
	"Huh? 
	What's that?", 
	"What do you mean by: 
	''Make him taste my finger salad''
	? ? ?",
	"Well...
	Whatever you do I'm here to help!
	As your trusty AI, as always!",
	"Let me know what you thought of
	this little test here! :D"
	
	]

var typing_speed = 0.075
var read_time = 2
var current_message = 0
var display = ""
var current_character = 0

func _ready():
	start_dialogue()
func start_dialogue():
	var current_message = 0
	var display = ""
	var current_character = 0
	$Text_Bubble.play("default")
	$Muse_AI.play("speaking")
	$next_char.set_wait_time(typing_speed)
	$next_char.start()
	
func stop_dialogue():
	queue_free()
	
func _on_next_char_timeout():
	if (current_character < len(messages[current_message])):
		var next_char = messages[current_message][current_character]
		display += next_char
		
		$Label.text = display
		$AI_Speech_SFX.play()
		current_character += 1
		
	else:
		$next_char.stop()
		$next_message.one_shot = true
		$next_message.set_wait_time(read_time)
		$next_message.start()
		$Muse_AI.play("idle")
		
func _on_next_message_timeout():
	if (current_message == len(messages) - 1):
		
		stop_dialogue()
	else:
		current_message += 1
		display = ""
		current_character = 0
		$next_char.start()
		$Muse_AI.play("speaking")
