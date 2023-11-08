extends PlayerState


var iframes_timer : Timer
signal started
signal finished


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await(owner.ready)
	
	iframes_timer = Timer.new()
	iframes_timer.set_wait_time(0.5)
	iframes_timer.timeout.connect(_on_iframes_timer_timeout)
	
	started.connect(player._on_iframes_started)
	finished.connect(player._on_iframes_finished)
	add_child(iframes_timer)
	iframes_timer.start()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta):
	player.move_and_slide() # necessary for is_on_floor()

func _enter(_msg := {}):
	iframes_timer.start()
	started.emit()
	$HurtFlash.show()
	
func _exit():
	$HurtFlash.hide()

func _on_iframes_timer_timeout():
	finished.emit()
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")
		
