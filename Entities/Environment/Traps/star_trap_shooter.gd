extends AnimatableBody2D

enum Goals { RELAX, RELOCATE, SHOOT_PLAYER }

var Goal : Goals = Goals.RELAX
var previous_goal : Goals

@export var SPEED : float = 100.0

var health_max : float = 20
var health = health_max

signal hurt(attackPacket)

func _ready():
	$DecisionTimer.start()
	$CPUParticles2D.emitting = false
	



func choose_random_goal():
	var dice_roll = randf()
	if dice_roll < 0.1:
		Goal = Goals.RELAX
	elif dice_roll < 0.4:
		Goal = Goals.RELOCATE
	else:
		Goal = Goals.SHOOT_PLAYER

func _on_decision_timer_timeout():
		
	$Behaviours/Attacks/ShootStars.stop_shooting() 

	previous_goal = Goal
	choose_random_goal()
	
	if Goal == Goals.SHOOT_PLAYER:
		$Behaviours/Attacks/ShootStars.start_shooting()
	
	elif Goal == Goals.RELOCATE:
		# choose a location near the player and go there.
		var distance = randf_range(64.0, 128.0)
		var angle = randf_range(-3.1415, 3.1415)
		var random_location = StageManager.current_player.global_position + (Vector2.ONE * distance).rotated(angle)
		var tween = create_tween()
		tween.tween_property(self, "global_position", random_location, 2.0 )
	
	$DecisionTimer.start()
	$Debug.global_rotation = 0.0
	$Debug/StateLabel.text = Goals.keys()[Goal]

func _on_shot_requested():
	$AnimationPlayer.play("shoot")
	
func die():
	
	$Behaviours/Attacks/ShootStars.stop_shooting()
	$CPUParticles2D.lifetime = 1.0
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(0.8).timeout
	queue_free()
	
func _on_hit(attackPacket):
	health -= attackPacket.damage
	hurt.emit(attackPacket)
	if health <= 0:
		die()
	else:
		$CPUParticles2D.lifetime = 0.33
		$CPUParticles2D.emitting = true
		$AnimatedSprite2D.material.set_shader_parameter("IFrames", true)
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.material.set_shader_parameter("IFrames", false)
		$CPUParticles2D.emitting = false