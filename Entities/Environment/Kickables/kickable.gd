extends RigidBody2D

var pushed = false
var push_iframes_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	push_iframes_timer = Timer.new()
	push_iframes_timer.set_wait_time(0.15)
	add_child(push_iframes_timer)
	push_iframes_timer.timeout.connect(_on_push_iframes_timer_timeout)

func push(impactVector):
	if !pushed:
		apply_central_impulse(impactVector)
		pushed = true
		set_collision_mask_value(4, false)
		push_iframes_timer.start()
		
func _on_push_iframes_timer_timeout():
	pushed = false
	set_collision_mask_value(4, true)
