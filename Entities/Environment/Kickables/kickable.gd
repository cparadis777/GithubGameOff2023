extends RigidBody2D

var pushed = false
var push_iframes_timer : Timer
var decay_timer : Timer

var duration: float = 5.0 # less than or equal to 0 means permanent

# Called when the node enters the scene tree for the first time.
func _ready():
	push_iframes_timer = Timer.new()
	push_iframes_timer.set_wait_time(0.15)
	add_child(push_iframes_timer)
	push_iframes_timer.timeout.connect(_on_push_iframes_timer_timeout)

	if duration > 0:
		decay_timer = Timer.new()
		decay_timer.set_wait_time(duration)
		add_child(decay_timer)
		decay_timer.timeout.connect(_on_decay_timer_timeout)


func push(impactVector):
	if !pushed:
		apply_central_impulse(impactVector)
		pushed = true
		set_collision_mask_value(4, false)
		push_iframes_timer.start()
		decay_timer.start()
		$kick_noises.play()
		
func _on_push_iframes_timer_timeout():
	pushed = false
	set_collision_mask_value(4, true)

func _on_decay_timer_timeout():
	call_deferred("queue_free")
	
