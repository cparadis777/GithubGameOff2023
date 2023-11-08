extends Node2D

var melee_range : float = 35.0
var current_attack_num = 0
var attacks_per_sequence = 3

@export var damage : float = 25.0
@export var inflict_knockback : bool = true

var active : bool = false
var npc

enum States { INITIALIZING, IDLE, ATTACKING, RELOADING, PAUSED }
var State : States 

# Called when the node enters the scene tree for the first time.
func _ready():
	npc = owner


func activate():
	active = true

func attempt_to_attack():
	if $RecoilTimer.is_stopped() and $ReloadTimer.is_stopped():
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
		
func _on_reload_timer_timeout():
	current_attack_num = 0
	
func _on_recoil_timer_timeout():
	pass # Replace with function body.


func _on_hurt_box_body_entered(body):
	if body == StageManager.current_player or body.is_in_group("Player") or body.name.to_lower().has("player"):
		if body.has_method("_on_hit"):
			var impactVector = global_position.direction_to(body.global_position)
			var damageType = Globals.DamageTypes.IMPACT
			body._on_hit(damage, impactVector, damageType, inflict_knockback)
