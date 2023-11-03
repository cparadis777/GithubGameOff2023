extends Node2D

@export var target_weight:int
var current_weight:int


# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.value = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func add_weight(weight:int) -> void:
	self.current_weight += weight
	var new_percentage = Utils.normalize(self.current_weight, 0, target_weight)
	print(new_percentage)
	$ProgressBar.value = new_percentage

