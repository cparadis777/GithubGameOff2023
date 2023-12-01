extends Grid


@export var containerSlotScene:PackedScene
var container_slots:Dictionary



func generate_slots(shape:Vector2) -> void:
	for i in shape[0]:
		for j in shape[1]:
			var new_slot = containerSlotScene.instantiate()
			self.add_child(new_slot)
			new_slot.position =  Vector2(i*self.container_width, -j*self.container_height)
			self.container_slots[Vector2(i,j)] = new_slot


func set_container(container:Node2D, coordinate:Vector2) -> void:
	container.name = str(coordinate) + "_" + container.name
	self.container_slots[coordinate].add_child(container)
	
	#container.position = self.container_slots[coordinate].position
	#container.position = Vector2(coordinate.x * self.container_width, -coordinate.y *self.container_height)
	#self.container_slots[coordinate].container = container
