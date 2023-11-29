extends Area2D

var played : bool = false
@export var require_clear_room : bool = true
@export_multiline var override_text : String = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	if override_text != "":
		$AI_Tutorial_Text.override_text = override_text
		$AI_Tutorial_Text.setup_messages(override_text)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func is_room_clear():
	print(self.name , " : owner == ", owner.name)
	if not owner.has_method("get_local_entities"):
		return true # we're not in a BaseContainer.gd
	elif owner.get_local_entities("Enemies").size() == 0:
		return true
	else:
		return false

func _on_body_entered(body):
	if require_clear_room:
		if !is_room_clear():
			return
		
	if !played and body.is_in_group("Player"):
		played = true
		$AI_Tutorial_Text.activate()

func _on_switch_toggled(pressed):
	if has_node("AI_Tutorial_Text"):
		$AI_Tutorial_Text.activate()
	
func _on_linked(node):
	pass
