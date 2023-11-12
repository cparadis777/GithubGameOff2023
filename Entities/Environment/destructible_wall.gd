extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn_debris():
	$DebrisParticles.emitting = true
	

func demolish(impactVector):
	$DebrisParticles.direction = -impactVector
	for i in range(randi()%10):
		spawn_debris()
		$CollisionShape2D.call_deferred("set_disabled", true)
		$WallSprite.hide()
	$DemolitionNoises.play()

func _on_hit(attackPacket : AttackPacket):
	if attackPacket.damage_type == Globals.DamageTypes.IMPACT and attackPacket.knockback == true:
		demolish(attackPacket.impact_vector)


func _on_demolition_noises_finished():
	call_deferred("queue_free")
