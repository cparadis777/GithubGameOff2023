extends StaticBody2D

@export var exterior_texture:Texture2D
@export var interior_texture:Texture2D
var weigth:int = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	$Exterior.texture = exterior_texture
	$Interior.texture = interior_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_container_interior_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		print("Showing outside container")
		$Exterior.show()

func _on_container_interior_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		print("Hidden outside container")
		$Exterior.hide()

func set_mode(mode:String) -> void:
	if mode == "GHOST":
		$Exterior.modulate = Color("005859")
	if mode == "REAL":
		$Exterior.modulate = Color("ffffff")
