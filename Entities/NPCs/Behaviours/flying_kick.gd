extends Node2D

signal finished

enum States { INACTIVE, ACTIVE }
var State = States.INACTIVE

# Called when the node enters the scene tree for the first time.
func _ready():
	activate() # for now

func activate():
	State = States.ACTIVE
	
func _process(_delta):
	pass

func start():
	pass
	
func stop():
	pass
	
func pause():
	pass

func resume():
	pass
	
