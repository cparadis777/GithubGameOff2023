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
## Originator (attacker) provides it to recipient (injured entity).
## Recipient forwards it to StageManager after processing for armor and block.

extends RefCounted

var time : float ## milliseconds since creation
var originator : Node2D ## Attacker
var recipient : Node2D ## Defender or Injured Party

var damage : float = 10 ## Harm to be inflicted, before block
var impact_vector : Vector2 = Vector2.RIGHT ## The direction knockback should proceed in, and injury particles might reflect away from.
var damage_type : Globals.DamageTypes = Globals.DamageTypes.IMPACT ## Recipients may need this to calculate their damage resistance and effective knockback
var knockback : bool = true ## Whether or not to fly in the direction of impact_vector
var knockback_speed : float = 100.0 ## How fast to fly.

var hit_stop_duration : int = 40 ## In msec. Sometimes its nice to have attacker and defender pause the moment an attack lands.  - 60fps =~ 17msec per frame. 


var movement_bound_to_attacker : bool = false ## If the recipient respects this, they will beging matching the originators movment and velocity
var movement_bind_msecs : int = 200 ## Number of milliseconds to bing movement toghether as a dance

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
	if persistent: # why?
		StageManager.persistent_attack_packets.push_back(self)
		


