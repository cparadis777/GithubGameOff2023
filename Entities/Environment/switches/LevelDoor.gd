extends Area2D

#Defines whether an exit is a horizontal doorway vertical ladder/hatch
enum DoorOrientation {HORIZONTAL, VERTICAL}

@export var next_scene:PackedScene
# how long to wait on a b screen before next scene
@export_range(0.0, 2.0, 0.1) var wait_seconds:float = 0.0
# how long this side of the transition animation will take
@export_range(0.0, 2.0, 0.1) var transition_seconds:float = 0.5
@export var unlocked:bool = true;
@export var orientation:DoorOrientation = DoorOrientation.HORIZONTAL
@export var location:Utils.Directions

var player_near : bool = false
var pressed : bool = false

signal level_exited()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.hide();
	pass # Replace with function body.

func exit_level():
	print_debug("exit_level()")
	# temporarily disable input and world physics, but next level must re-enable?
	get_tree().get_root().set_process_input(false)
	
	level_exited.emit()
	
	SceneTransition.change_scene(next_scene, wait_seconds)
	await get_tree().create_timer(wait_seconds + transition_seconds).timeout
	

# Should be done on load of a level
func enter_level():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and player_near and unlocked and !pressed:
		pressed = true;
		exit_level()
	if pressed:
		StageManager.current_player.velocity.x = StageManager.current_player.speed

func _on_body_entered(body):
	if body == StageManager.current_player:
		player_near = true
		$Label.show()
	
func _on_body_exited(body):
	if body == StageManager.current_player:
		player_near = false
		$Label.hide()
