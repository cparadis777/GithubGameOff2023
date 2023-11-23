extends Node2D


var iframes_timer : Timer
signal started
signal finished
@export var iframes_duration : float = 0.4

@onready var active: bool:
	get:
		return !iframes_timer.is_stopped()

# Called when the node enters the scene tree for the first time.
func _ready():

	await owner.ready
	
	iframes_timer = Timer.new()
	iframes_timer.one_shot = true
	iframes_timer.set_wait_time(iframes_duration)
	iframes_timer.timeout.connect(_on_iframes_timer_timeout)
	
	started.connect(owner._on_iframes_started)
	finished.connect(owner._on_iframes_finished)
	add_child(iframes_timer)
	
	
	

func start():
	iframes_timer.start()
	started.emit()
	$HurtFlash.show()


func _on_iframes_timer_timeout():
	$HurtFlash.hide()
	finished.emit()


