extends Node2D

enum States { INACTIVE, ACTIVE } 
var State = States.INACTIVE

var npc

# Called when the node enters the scene tree for the first time.
func _ready():
	npc = owner
	$ReloadTimer.timeout.connect(_on_reload_timer_timeout)
	$DefendTimer.timeout.connect(_on_defend_timer_timeout)
	$ShieldAura.hide()

func activate():
	State = States.ACTIVE

func is_active():
	return (State == States.ACTIVE)

func attempt_to_defend():
	if npc.State in [npc.States.DYING, npc.States.DEAD, npc.States.IFRAMES]:
		return
	
	elif $ReloadTimer.is_stopped() and $DefendTimer.is_stopped():
		initiate_shield_arm_defense()
		
func initiate_shield_arm_defense():
	if npc.State in [npc.States.DYING, npc.States.DEAD, npc.States.IFRAMES]:
		return
		
	else:
		npc.animation_player.play("defend")
		npc.State = npc.States.DEFENDING
		$DefendTimer.start()


func _on_defend_timer_timeout():
	if npc.State in [npc.States.DYING, npc.States.DEAD, npc.States.IFRAMES]:
		return
	else:
		npc.State = npc.States.ALERT
		$ReloadTimer.start()
	
func _on_reload_timer_timeout():
	pass

func _on_hit(_attackPacket : AttackPacket):
	if npc.State in [npc.States.DYING, npc.States.DEAD, npc.States.IFRAMES]:
		return
	else:
		$DefenseNoise.play()
		$ShieldAura.show()
		var timer = get_tree().create_timer(0.2)
		timer.timeout.connect($ShieldAura.hide)
	
