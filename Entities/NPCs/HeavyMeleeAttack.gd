extends Node2D

var melee_range : float = 35.0
var current_attack_num = 0
var attacks_per_sequence = 3

#var damage : float = 10.0
@export var inflict_knockback : bool = true

var active : bool = false
var npc

enum States { INITIALIZING, IDLE, ATTACKING, RELOADING, PAUSED }
var State : States 

signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	npc = owner
	#damage = npc.base_damage
	

func activate():
	active = true
	


func attempt_to_attack():
	if $RecoilTimer.is_stopped() and $ReloadTimer.is_stopped():
		if StageManager.current_player != null:
			var playerPos = StageManager.current_player.global_position
			if global_position.distance_squared_to(playerPos) < melee_range * melee_range:
				attack()

func is_active():
	return active

func attack():
	
	if npc.get_node("AnimationPlayer").has_animation("melee_attack"):
		if current_attack_num < attacks_per_sequence:
			npc.get_node("AnimationPlayer").play("melee_attack")
			current_attack_num += 1
			$RecoilTimer.start()
		else:
			$ReloadTimer.start()

func stop():
	$HurtBox/CollisionPolygon2D.set_deferred("disabled", true)
	$RecoilTimer.stop()
	$ReloadTimer.stop()
	current_attack_num = 0
	

func _on_reload_timer_timeout():
	current_attack_num = 0
	
func _on_recoil_timer_timeout():
	pass # Replace with function body.


func _on_hurt_box_body_entered(body):
	if body == StageManager.current_player or body.is_in_group("Player") or "player" in body.name.to_lower():
		if body.has_method("_on_hit"):
			var attackPacket = AttackPacket.new()
			attackPacket.originator = self
			attackPacket.recipient = body
			attackPacket.damage = npc.base_damage
			attackPacket.impact_vector = global_position.direction_to(body.global_position)
			attackPacket.damage_type = Globals.DamageTypes.IMPACT
			
			hit.connect(body._on_hit)
			hit.emit(attackPacket)
			hit.disconnect(body._on_hit)
