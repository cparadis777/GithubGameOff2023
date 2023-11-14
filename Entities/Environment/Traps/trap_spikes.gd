extends Area2D
@export var damage = 5

signal hit

func harm(body):
	var attackPacket = AttackPacket.new()
	attackPacket.damage = damage
	attackPacket.originator = self
	attackPacket.recipient = body
	attackPacket.impact_vector = -body.velocity
	attackPacket.knockback = true
	attackPacket.knockback_speed = 200.0
	hit.connect(body._on_hit)
	hit.emit(attackPacket)
	hit.disconnect(body._on_hit)
	

func _on_body_entered(body):
	if body.has_method("_on_hit"):
		harm(body)
