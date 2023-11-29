extends Area2D
@export var base_damage = 5
var damage = base_damage

signal hit

func _ready():
	damage = base_damage * ( 1 + Globals.difficulty / Globals.DifficultyScales.size())
	
	
func harm(body):
	var attackPacket = AttackPacket.new()
	attackPacket.damage = damage
	attackPacket.originator = self
	attackPacket.recipient = body
	if body.get("velocity"):
		attackPacket.impact_vector = Vector2(sign(body.velocity.x), -1.0)
	else:
		attackPacket.impact_vector = Vector2(global_position - body.position)
	attackPacket.knockback = true
	attackPacket.knockback_speed = 50.0
	hit.connect(body._on_hit)
	hit.emit(attackPacket)
	hit.disconnect(body._on_hit)
	

func _on_body_entered(body):
	# can harm player or NPCs
	if body.has_method("_on_hit"):
		harm(body)


func _on_continuous_damage_timer_timeout():
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") or body.is_in_group("Enemies"):
			harm(body)
