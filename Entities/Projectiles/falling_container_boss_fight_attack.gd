extends RigidBody2D

@export var damage : float = 10.0

signal hit(attackPacket)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !freeze:
		if linear_velocity.y < 0.1:
			freeze = true
			$Hurtbox.monitoring = false
			

func activate(initial_velocity):
	global_position = get_tree().get_first_node_in_group("CraneJaws").global_position + Vector2.DOWN * 96
	
	rotation = 0
	#apply_central_impulse( initial_velocity )

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player") and not linear_velocity.is_zero_approx():
		var attackPacket : AttackPacket = AttackPacket.new()
		attackPacket.originator = self
		attackPacket.recipient = body
		attackPacket.damage = (1 + Globals.difficulty * damage)
		attackPacket.impact_vector = self.global_position.direction_to(body.global_position)
		hit.connect(body._on_hit)
		hit.emit(attackPacket)
		hit.disconnect(body._on_hit)

