extends Node2D

@export var base_damage : float = 5.0
@export var enabled : bool = true
@export var knockback_speed : float = 150

var damage
var npc

enum States { INACTIVE, ACTIVE }
var State = States.INACTIVE

signal started
signal hit
signal finished


# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	npc = owner
	scale_for_difficulty()
	started.connect(owner._on_melee_attack_started)
	finished.connect(owner._on_melee_attack_finished)
	
func scale_for_difficulty():
	damage = base_damage * (1+float(Globals.difficulty)/20.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !enabled or State == States.INACTIVE:
		return
	
	if npc.State in [npc.States.IDLE, npc.States.RUNNING]:
		if $AttackDelay.is_stopped() and $AttackReload.is_stopped():
			if $RayCast2D.is_colliding() and $RayCast2D.get_collider() == StageManager.current_player:
				launch_attack()


func launch_attack():
	$AttackDelay.set_wait_time(randf_range(0.1, 0.3))
	$AttackDelay.start()
	

func execute_attack():
	started.emit() # make the NPC play their own animation
	$AttackReload.start()
	#$AnimationPlayer.play("attack")
			

func start():
	State = States.ACTIVE

func stop():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("RESET")
	$AttackDelay.stop()
	$AttackReload.stop()
	
	

func _on_attack_delay_timeout():
	if npc.State in [npc.States.IDLE, npc.States.RUNNING]:
		execute_attack()
	
func _on_attack_reload_timeout():
	finished.emit()
	

func is_enemy(body):
	if body == StageManager.current_player:
		return true
	else:
		return false

func inflict_harm(body):
	var attackPacket = AttackPacket.new()
	attackPacket.damage = damage
	attackPacket.originator = owner
	attackPacket.impact_vector = owner.global_position.direction_to(body.global_position)
	attackPacket.recipient = body
	attackPacket.knockback = true
	attackPacket.knockback_speed = knockback_speed
	if body.has_method("_on_hit"):
		hit.connect(body._on_hit)
		hit.emit(attackPacket)
		hit.disconnect(body._on_hit)
	else:
		printerr("simple_melee_attack tried to connect, but the recipient has no _on_hit method. " + owner.name + " , " + body.name)

func _on_melee_collision_area_body_entered(body):
	if owner.State not in [ owner.States.DYING, owner.States.DEAD ]:
		if is_enemy(body):
			inflict_harm(body)


#func _on_animation_player_animation_finished(anim_name):
#	if anim_name == "attack":
#		finished.emit()
