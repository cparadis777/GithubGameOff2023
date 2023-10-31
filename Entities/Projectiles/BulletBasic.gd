extends Area2D

@export var speed = 350.0
@export var velocity : Vector2

signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func activate(travelVector):
	velocity = (travelVector * speed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if velocity != null:
		position += velocity * delta


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
		hit.emit()
		queue_free()
