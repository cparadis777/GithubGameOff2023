extends RigidBody2D

var kicked = false

@export var soda_can : PackedScene = preload("res://Entities/Environment/Kickables/soda_can.tscn")
@export var max_hits = 2
@export var chance_to_spawn_health = 1.0
var hits = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for crack in $DamageSprites.get_children():
		crack.hide()

func spawn_soda_cans(impactVector):
	for i in range(randi_range(3,7)):
		var new_soda_can : RigidBody2D = soda_can.instantiate()
		var distance = 16.0
		var jitter = 0.3 # radians
		var bounce_vector = impactVector.normalized().rotated(randf_range(-jitter, jitter))
		call_deferred("add_sibling", new_soda_can)
		new_soda_can.global_position = self.global_position - bounce_vector * distance
		await new_soda_can.ready
		new_soda_can.apply_central_impulse(bounce_vector)

func spawn_cracks():
	for sprite in $DamageSprites.get_children():
		if sprite.get_index() < hits:
			sprite.show()
		else:
			sprite.hide()
			
func die():
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()

func spawn_health_pickup():
	var health_pickup = preload("res://Entities/Environment/Pickables/health_pickable.tscn").instantiate()
	call_deferred("add_sibling", health_pickup)
	health_pickup.global_position = global_position
	health_pickup.position += Vector2.ONE.rotated(randf()*TAU) * 3.0
	

func _on_hit(attackPacket : AttackPacket):
	if !kicked:
		spawn_soda_cans(attackPacket.impact_vector)
		if randf() <= chance_to_spawn_health:
			spawn_health_pickup()
		
	freeze = false
	var knockbackMultiplier = 1.5
	$HurtNoises.play()
	apply_central_impulse( (attackPacket.impact_vector + Vector2.UP) * attackPacket.knockback_speed * knockbackMultiplier)
	kicked = true
	hits += 1
	spawn_cracks()
	if hits > max_hits:
		die()
	
