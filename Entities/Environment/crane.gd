extends Node2D


@export var n_columns:int
@export var containers:Array[PackedScene]
@export var container_width:int
@export var drop_zone:Node2D

var current_container 
var move_ready:bool
var current_column:int
var markers:Array
var move_time:float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	self.create_markers()
	self.set_current_container(select_random_container())
	#self.move_ready = true
	%WeightLabel.text = "%s,000 kg" % self.current_container.weight
	%TypeLabel.text = "%s" % self.current_container.type
	

func activate():
	self.move_ready = true

func deactivate():
	self.move_ready = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	if self.move_ready:
		if event.is_action_pressed("move_right"):
			self.move_container(Utils.Directions.RIGHT)
		elif event.is_action_pressed("move_left"):
			self.move_container(Utils.Directions.LEFT)
		elif event.is_action_pressed("jump"):
			self.place_container()
		elif event.is_action_pressed("rotate_left"):
			self.rotate_container("CCW")
		elif event.is_action_pressed("rotate_right"):
			self.rotate_container("CW")	

func select_random_container() -> StaticBody2D:
	var new_container = containers.pick_random().instantiate()
	#new_container.get_node("Exterior").self_modulate = Utils.random_color()
	self.randomize_container_access(new_container)
	new_container.weight = 100 * randf()
	return new_container

func set_current_container(container:StaticBody2D):
	self.current_container = container
	self.add_child(self.current_container)
	self.current_container.position = markers[current_column].position
	$CraneJaw.position[0] = markers[current_column].position[0]
	%TypeLabel.text = "%s" % self.current_container.type

func create_markers() -> void:
	for i in range(n_columns):
		var new_marker = Marker2D.new()
		new_marker.position = Vector2(i*self.container_width, 0)
		self.add_child(new_marker)
		self.markers.append(new_marker)

func move_container(direction:Utils.Directions) -> void:
	if self.move_ready:
		match direction:
			1:
				if current_column < n_columns - 1:
					self.move_ready = false
					self.current_column += 1	
					var tween = get_tree().create_tween().set_parallel(true)
					tween.finished.connect(move_done)
					tween.tween_property(self.current_container, "position", self.markers[self.current_column].position, self.move_time)
					tween.tween_property($CraneJaw, "position", Vector2(self.markers[self.current_column].position[0], $CraneJaw.position[1]), self.move_time)
				else:
					pass
			3:
				if current_column != 0:
					self.move_ready = false
					self.current_column -= 1
					var tween = get_tree().create_tween().set_parallel(true)
					tween.finished.connect(move_done)
					tween.tween_property(self.current_container, "position", self.markers[self.current_column].position, self.move_time)
					tween.tween_property($CraneJaw, "position", Vector2(self.markers[self.current_column].position[0], $CraneJaw.position[1]), self.move_time)
				else:
					pass
		
func place_container() -> void:
	if drop_zone.check_drop_possible(self.current_column):
		self.move_ready = false
		drop_zone.place_container(self.current_container, current_column)
		self.current_container = null
		$CraneJaw.play()
		
func refesh_container() -> void:
	self.set_current_container(select_random_container())
	self.move_ready = true
	%WeightLabel.text = "%s,000 kg" % self.current_container.weight

func move_done()->void:
	self.move_ready = true

func randomize_container_access(container) -> void:
	var sides = {
		Utils.Directions.LEFT: false,
		Utils.Directions.UP: false, 
		Utils.Directions.RIGHT: false,
		Utils.Directions.DOWN: false,
	}
	var sides_list = sides.keys()

	var guaranteed_number_of_exits = 2
	for i in range(guaranteed_number_of_exits):
		var side = sides_list.pick_random()
		sides_list.erase(side)
		sides[side] = true
	for i in range(4-guaranteed_number_of_exits):
		if randf() > 0.5:
			var side = sides_list.pick_random()
			sides_list.erase(side)
			sides[side] = true

	container.set_entrances(sides)

func rotate_container(rotation_direction:String) -> void:
	var previous_exits:Dictionary = self.current_container.entrances
	var new_exits:Dictionary = {Utils.Directions.UP: false, Utils.Directions.RIGHT: false, Utils.Directions.DOWN: false, Utils.Directions.LEFT: false}
	for direction in previous_exits:
		if rotation_direction == "CW":
			new_exits[Utils.get_next_direction(direction)] = previous_exits[direction]
		elif rotation_direction == "CCW":
			new_exits[Utils.get_previous_direction(direction)] = previous_exits[direction]
		else:
			pass

	self.current_container.set_entrances(new_exits)

func _on_crane_jaw_animation_finished():
	$CraneJaw.set_frame(0)
