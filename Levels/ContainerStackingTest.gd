extends Node2D

@export var Container_scene:PackedScene
var container_move_ready:bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	var container = Container_scene.instantiate()
	self.set_current_container(container)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if container_move_ready:
		if event.is_action_pressed("move_right"):
			$DropPoints.move_container(Utils.Directions.RIGHT)
		elif event.is_action_pressed("move_left"):
			$DropPoints.move_container(Utils.Directions.LEFT)
		elif event.is_action_pressed("move_up"):
			$DropPoints.move_container(Utils.Directions.UP)
		elif event.is_action_pressed("move_down"):
			$DropPoints.move_container(Utils.Directions.DOWN)
		elif event.is_action_pressed("jump"):
			if $DropPoints.place_container():
				var container = Container_scene.instantiate()
				self.set_current_container(container)

func set_current_container(container:StaticBody2D):
	$DropPoints.set_current_container(container)
