extends Area2D

var player_near : bool = false
var pressed : bool = false

@export var next_scene:PackedScene
@export_range(0.0, 2.0, 0.1) var wait_seconds:float = 0.0

signal toggled(pressed)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide();
	pass # Replace with function body.

func level_transition():
	print_debug("level_transition()")
	toggled.emit(pressed)
	SceneTransition.change_scene(next_scene, wait_seconds)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !pressed and Input.is_action_just_pressed("interact") and player_near:
		pressed = true;
		level_transition()

func _on_body_entered(body):
	if body == StageManager.current_player:
		player_near = true
		$Label.show()
	
func _on_body_exited(body):
	if body == StageManager.current_player:
		player_near = false
		$Label.hide()
