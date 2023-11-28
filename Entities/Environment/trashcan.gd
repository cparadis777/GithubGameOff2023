extends RigidBody2D

var kicked = false

@export var soda_can : PackedScene = preload("res://Entities/Environment/Kickables/soda_can.tscn")
@export var max_hits = 2

var original_position : Vector2

@export var chance_to_spawn_anything: float = 0.67

@export var spawn_probabilities = {
	Globals.PickupTypes.HEALTH : 0.4,
	Globals.PickupTypes.DAMAGE : 0.2,
	Globals.PickupTypes.JUMP : 0.2,
	Globals.PickupTypes.SPEED : 0.2,
}

@export var pickup_scenes = {
	Globals.PickupTypes.HEALTH : preload("res://Entities/Environment/Pickables/health_pickable.tscn"),
	Globals.PickupTypes.DAMAGE : preload("res://Entities/Environment/Pickables/damage_pickable.tscn"),
	Globals.PickupTypes.JUMP : preload("res://Entities/Environment/Pickables/jump_pickable.tscn"),
	Globals.PickupTypes.SPEED : preload("res://Entities/Environment/Pickables/speed_pickable.tscn"),
}

var hits = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for crack in $DamageSprites.get_children():
		crack.hide()
	await get_tree().create_timer(0.3).timeout
	original_position = get_global_position()
	
	


func spawn_soda_cans(impactVector):
	for i in range(randi_range(3,7)):
		var new_soda_can : RigidBody2D = soda_can.instantiate()
		var distance = 16.0
		var jitter = 0.3 # radians
		var bounce_vector = impactVector.normalized().rotated(randf_range(-jitter, jitter))
		call_deferred("add_sibling", new_soda_can)
		await new_soda_can.ready
		new_soda_can.global_position = self.global_position - bounce_vector * distance
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

func spawn_random_pickup():
	var pickup_scene
	var running_chance : float = 0.0
	var dice_roll : float = randf()
	for type in spawn_probabilities.keys():
		running_chance += spawn_probabilities[type]
		if dice_roll < running_chance:
			pickup_scene = pickup_scenes[type]
			dice_roll = 100.0 # so no one else can get it.

	if pickup_scene != null:
		var pickup = pickup_scene.instantiate()
	
		call_deferred("add_sibling", pickup)
		await pickup.ready
		pickup.global_position = global_position
		pickup.position += Vector2.ONE.rotated(randf()*TAU) * 3.0
		

func _on_hit(attackPacket : AttackPacket):
	if !kicked:
		spawn_soda_cans(attackPacket.impact_vector)
		if randf() < chance_to_spawn_anything:
			spawn_random_pickup()
		kicked = true

	freeze = false # act as a rigid body, not a static body
	var knockbackMultiplier = 1.5
	$HurtNoises.play()
	apply_central_impulse( (attackPacket.impact_vector + Vector2.UP) * attackPacket.knockback_speed * knockbackMultiplier)
	hits += 1
	spawn_cracks()
	if hits > max_hits:
		die()
	
