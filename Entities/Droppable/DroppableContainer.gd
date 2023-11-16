extends StaticBody2D

var weigth:int = 100
var grid_position:Vector2 = Vector2(100,100)
@export var type: ContainerProperties.container_type = ContainerProperties.container_type.YELLOW

var entrances = {
	Utils.Directions.LEFT: false,
	Utils.Directions.UP: false,
	Utils.Directions.RIGHT: false,
	Utils.Directions.DOWN: false,
}


func set_grid_position(coordinate:Vector2) -> void:
	self.grid_position = coordinate
	$Label.text = "%s" % coordinate


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



