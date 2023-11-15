extends StaticBody2D

@export var exterior_texture:Texture2D

var weigth:int = 100
var grid_position:Vector2 = Vector2(100,100)
var type: ContainerProperties.container_type = ContainerProperties.container_type.BLUE

var entrances = {
	Utils.Directions.LEFT: false,
	Utils.Directions.UP: false,
	Utils.Directions.RIGHT: false,
	Utils.Directions.DOWN: false,
}

# entrance_arrows:Dictionary = {Utils.Directions.LEFT: null}
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
	#print("setting arrows")

	#print("done setting arrows")


func set_grid_position(coordinate:Vector2) -> void:
	self.grid_position = coordinate
	$Label.text = "%s" % coordinate



func _on_container_interior_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		print("Showing outside container")
		$Exterior.show()

func _on_container_interior_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		print("Hidden outside container")
		$Exterior.hide()

func set_entrances(directions) -> void:

	var entrance_arrows = {
	Utils.Directions.LEFT: $LeftLine,
	Utils.Directions.UP: $UpLine,
	Utils.Directions.RIGHT: $RightLine,
	Utils.Directions.DOWN: $DownLine,
}

	for entrance in entrance_arrows:
		#print("BaseContainer.gd: entrange = " + str(entrance))
		entrance_arrows[entrance].hide()
	for direction in directions:
		self.entrances[direction] = true
		entrance_arrows[direction].show()

func hide_entrance(direction) -> void:
	return
	var entrance_arrows = {
	Utils.Directions.LEFT: $LeftLine,
	Utils.Directions.UP: $UpLine,
	Utils.Directions.RIGHT: $RightLine,
	Utils.Directions.DOWN: $DownLine,
}
	entrance_arrows[direction].hide()


