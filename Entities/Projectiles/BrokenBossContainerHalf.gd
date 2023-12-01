extends RigidBody2D

var fragment_scene : PackedScene = preload("res://Entities/Projectiles/container_fragment.tscn")
var demolished : bool = false


func demolish(attackPacket : AttackPacket):
	# spawn particles and 3 smaller rigid bodies
	$CPUParticles2D.emitting = true
	for i in range(randi_range(3,5)):
		var newFragment : RigidBody2D = fragment_scene.instantiate()
		get_tree().get_root().call_deferred("add_child", newFragment)
		var jitter = Vector2(randi_range(-64,64), randi_range(-64,64))
		newFragment.call_deferred("activate", global_position + jitter, attackPacket.impact_vector * attackPacket.knockback_speed )
	
	self.collision_layer = 0
	self.collision_mask = 0
	self.call_deferred("queue_free")

func _on_hit(attackPacket):
	if !demolished:
		demolish(attackPacket)
		demolished = true
