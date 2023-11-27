extends Area2D


@export var next_scene:PackedScene
# how long to wait on a b screen before next scene
@export_range(0.0, 2.0, 0.1) var wait_seconds:float = 0.0
# how long this side of the transition animation will take
@export_range(0.0, 2.0, 0.1) var transition_seconds:float = 0.5
@export var unlocked:bool = true;
@export var move_player:bool = false;
@export var location:Utils.Directions

var player_near : bool = false
var pressed : bool = false

signal level_exited()

# Called when the node enters the scene tree for the first time.
func _ready():
	%Label.hide()
	%Sprite2D.hide()
	pass # Replace with function body.

func exit_level():
	# print_debug("exit_level()")
	
	level_exited.emit(location)
	SceneTransition.change_scene(next_scene, transition_seconds, wait_seconds)
	

# Should be done on load of a level
func enter_level():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_near and unlocked and !pressed:
		pressed = true;
		exit_level()
	if pressed && move_player:
		match(location):
			Utils.Directions.LEFT:
				StageManager.current_player.velocity.x = -(Globals.player_stats["speed"])
			Utils.Directions.RIGHT:
				StageManager.current_player.velocity.x = Globals.player_stats["speed"]
			Utils.Directions.UP:
				StageManager.current_player.velocity.y = -(Globals.player_stats["speed"])
			Utils.Directions.DOWN:
				StageManager.current_player.velocity.y = Globals.player_stats["speed"]
		

func _on_body_entered(body):
	if body == StageManager.current_player:
		player_near = true
		%Label.show()
		%Sprite2D.show()
	
func _on_body_exited(body):
	if body == StageManager.current_player:
		player_near = false
		%Label.hide()
		%Sprite2D.show()
