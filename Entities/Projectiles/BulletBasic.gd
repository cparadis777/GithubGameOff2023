extends Area2D

@export var speed = 150.0
var velocity : Vector2
@export var damage : float = 5.0
@export var knockback : bool = true
@export var damage_type : Globals.DamageTypes
@export var affected_by_gravity : bool = false
@export var extra_initial_velocity : Vector2

var world_gravity

signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	world_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
func activate(travelVector):
	velocity = (travelVector * speed)
	velocity += Vector2(sign(travelVector.x) * extra_initial_velocity.x, extra_initial_velocity.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if world_gravity != null:
		if velocity != null:
			if affected_by_gravity:
				velocity.y += world_gravity * delta
			global_position += velocity * delta


func _on_timer_timeout():
	queue_free()

func explode():
	if $AnimationPlayer.has_animation("explode"):
		$AnimationPlayer.play("explode")

func _on_body_entered(body):
	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
		var attackPacket = AttackPacket.new()
		attackPacket.damage = damage
		attackPacket.originator = self
		attackPacket.recipient = body
		attackPacket.impact_vector = velocity.normalized()
		attackPacket.damage_type = Globals.DamageTypes.IMPACT
		attackPacket.knockback = knockback
		attackPacket.knockback_speed = 100.0
		hit.emit(attackPacket)
		call_deferred("queue_free")
	else:
		explode()

