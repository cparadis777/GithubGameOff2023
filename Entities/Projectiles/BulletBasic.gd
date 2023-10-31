extends Area2D

@export var speed = 20.0
@export var velocity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func activate(travelVector):
	velocity = (travelVector * speed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if velocity != null:
		position += velocity


func _on_timer_timeout():
	queue_free()
