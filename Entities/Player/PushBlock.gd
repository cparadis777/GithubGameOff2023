"""
Meant to push cans out of the way when executing a strong punch or whatever.

"""
extends Area2D

var damage = 10
signal pushed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_body_entered(body):
	if body.is_in_group("Pushables"):
		if body.has_method("push"):
			pushed.connect(body.push)
			var magnitude = 4.5
			pushed.emit((global_position.direction_to(body.global_position) + Vector2.UP ) * magnitude)
			pushed.disconnect(body.push)

		# kickables don't have _on_hit
#		if body.has_method("_on_hit"):
#			var attackPacket : AttackPacket = AttackPacket.new()
#			attackPacket.impact_vector = owner.global_position.direction_to(body.global_position) + Vector2.UP
#			attackPacket.knockback = true
#			attackPacket.knockback_speed = 40
#			attackPacket.originator = owner
#			attackPacket.recipient = body
#			attackPacket.damage = damage
#			body._on_hit(attackPacket)
