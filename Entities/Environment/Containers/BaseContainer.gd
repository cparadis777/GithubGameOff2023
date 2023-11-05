extends StaticBody2D

@export var exterior_texture:Texture2D
@export var interior_texture:Texture2D
var weigth:int = 100
var grid_position:Vector2 = Vector2(100,100)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Exterior.texture = exterior_texture
	$Interior.texture = interior_texture


func set_grid_position(coordinate:Vector2) -> void:
	self.grid_position = coordinate
	$Label.text = "%s" % coordinate
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
