"""
CombatPackets: inspired by Timothy Cain in this talk:
	https://www.youtube.com/watch?v=ltO_rMJJdHE

Combat is like a dance: 
	dancers have to lead and follow.
	
Attack Packets deliver information about each attack. 
	damage, impact_vector, etc.

They could also contain logic
	so the injured-party knows how to follow the lead.

Note: other systems, besides the attacker and defender, 
	may be interested in these packets. UI, VFX, nearby entities, etc.

Bonus: NPCs can keep a list of all the injury they sustained, from whom, and when.


=-=- This might be overkill for a game jam. -=-=

"""

class_name AttackPacket

extends Node2D

var time : float # msec
var originator : Node2D
var recipient : Node2D

var damage : float = 10
var impact_vector : Vector2 = Vector2.RIGHT
var damage_type : Globals.DamageTypes = Globals.DamageTypes.IMPACT
var knockback : bool = true
var knockback_speed : float = 100.0

# sometimes its nice to have attacker and defender pause the moment an attack lands.
var hit_stop_duration : int = 40 # msec - 60fps =~ 17msec per frame

var movement_bound_to_attacker : bool = false
var movement_bind_msecs : int = 200 # msec

var preferred_defender_animation : String = ""

var damage_consumed : float # prevent double-dip accounting 
var damage_blocked : float
var damage_reflected : float

var persistent : bool = false # set persistent if you need to retain this packet
var msecs_before_self_destruct : int = 500 # msec
# set to -1 for persistent packets


# Called when the node enters the scene tree for the first time.
func _ready():
	time = Time.get_ticks_msec()
	if !persistent:
		set_self_destruct_timer()

func set_self_destruct_timer():
	if msecs_before_self_destruct > 0:
		var timer = get_tree().create_timer(float(msecs_before_self_destruct) / 1000.0)
		timer.timeout.connect(_on_self_destruct_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_self_destruct_timer_timeout():
	if !persistent:
		queue_free()
	
