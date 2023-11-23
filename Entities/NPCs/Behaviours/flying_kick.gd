extends Node2D

signal finished

enum States { INACTIVE, ACTIVE }
var State = States.INACTIVE
@export var enabled : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	activate() # for now

func activate():
	State = States.ACTIVE
	
func _process(_delta):
	pass

func start():
	State = States.ACTIVE
	
func stop():
	State = States.INACTIVE
	
func pause():
	pass

func resume():
	pass
	
