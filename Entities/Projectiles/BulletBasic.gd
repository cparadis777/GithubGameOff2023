extends Area2D

@export var speed = 150.0
@export var velocity : Vector2
@export var damage : float = 5.0
@export var knockback : bool = true
@export var damage_type : Globals.DamageTypes
signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func activate(travelVector):
	velocity = (travelVector * speed)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if velocity != null:
		global_position += velocity * delta


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
		var attackPacket = AttackPacket.new()
		attackPacket.damage = damage
		attackPacket.originator = self
		attackPacket.recipient = body
		attackPacket.impact_vector = velocity
		attackPacket.damage_type = Globals.DamageTypes.IMPACT
		attackPacket.knockback = knockback
		hit.emit(attackPacket)
		call_deferred("queue_free")
		
