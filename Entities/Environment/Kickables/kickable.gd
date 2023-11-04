extends RigidBody2D

var kicked = false
var kick_iframes_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	kick_iframes_timer = Timer.new()
	kick_iframes_timer.set_wait_time(0.15)
	add_child(kick_iframes_timer)
	kick_iframes_timer.timeout.connect(_on_kick_iframes_timer_timeout)

func kick(impactVector):
	if !kicked:
		apply_central_impulse(impactVector)
		kicked = true
		set_collision_mask_value(4, false)
		kick_iframes_timer.start()
		
func _on_kick_iframes_timer_timeout():
	kicked = false
	set_collision_mask_value(4, true)
