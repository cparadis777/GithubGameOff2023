extends NPC_Behaviour


@export var enabled: bool = false

enum States { INACTIVE, IDLE, MOVING, DROPPING, RELOADING }
var State : States = States.INACTIVE
var speed : float = 40.0
var direction : int = 1

func _ready():
	pass # Replace with function body.


func _process(_delta):
	if State == States.INACTIVE:
		return
	elif State == States.DROPPING:
		spawn_crate()
		State == States.RELOADING
		$ReloadTimer.start()
	elif State == States.MOVING:
		position.x += direction * speed
		

func spawn_crate():
	pass

func start():
	if enabled:
		State = States.MOVING
	
func stop():
	if enabled:
		State = States.IDLE
	
func activate():
	if enabled:
		State = States.IDLE
