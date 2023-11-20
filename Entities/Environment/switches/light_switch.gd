extends Area2D

var player_near : bool = false
var pressed : bool = false

@export var linked_nodes : Array[Node]
signal toggled(pressed)

# Called when the node enters the scene tree for the first time.
func _ready():
	link_nodes()
	
	
func link_nodes():
	for linked_node in linked_nodes:
		if linked_node != null and is_instance_valid(linked_node):
			if linked_node.has_method("_on_switch_toggled"):
				toggled.connect(linked_node._on_switch_toggled)
			if linked_node.has_method("_on_linked"):
				linked_node._on_linked(self)
				
				
func toggle_switch():
	var rotations = [ -PI/4.0, PI/4.0 ]
	var colors = [ Color.RED, Color.CORNFLOWER_BLUE ]
	pressed = !pressed
	var index = int(pressed)
	$Polygon2D.color = colors[index]
	$Polygon2D.rotation = rotations[index]
	$ClickNoise.play()
	toggled.emit(pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("interact") and $Timer.is_stopped():
		if StageManager.current_player in get_overlapping_bodies():
			toggle_switch()
			$Timer.start()

func _on_body_entered(body):
	if body == StageManager.current_player:
		player_near = true
	


func _on_body_exited(body):
	if body == StageManager.current_player:
		player_near = false
