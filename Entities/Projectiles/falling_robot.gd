extends RigidBody2D

var damage : float = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	pass

func activate(velocity):
	global_position = get_tree().get_first_node_in_group("CraneJaws").global_position + Vector2.DOWN * 128
	
	
