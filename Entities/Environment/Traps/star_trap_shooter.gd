extends AnimatableBody2D


enum Goals { RELAX, RELOCATE, SHOOT_PLAYER }

var Goal : Goals = Goals.RELAX
var previous_goal : Goals

@export var SPEED : float = 100.0
var mobile : bool = false

var health_max : float = 20
var health = health_max
var base_damage = 10


signal hurt(attackPacket)
signal died(name)

func _ready():
	$CPUParticles2D.emitting = false
	set_difficulty(Globals.difficulty)
	if has_node("Arrow"):
		$Arrow.hide()
		
func set_difficulty(difficulty : Globals.DifficultyScales):
	health_max += difficulty * 10.0
	SPEED += float(difficulty)/40.0 * 100.0
	base_damage *= (1+float(difficulty)/20.0)


func activate(): # from BaseContainer _on_body_entered
	_on_decision_timer_timeout() # get started immediately
	if owner and owner.has_method("_on_NPC_died"):
		if not died.is_connected(owner._on_NPC_died):
			died.connect(owner._on_NPC_died)
	
func choose_random_goal():
	var dice_roll = randf()
	var probabilities
	if mobile:
		probabilities = [0.3, 0.0, 0.7]
	else:
		probabilities = [0.3, 0.1, 0.6]
	
	if dice_roll < probabilities[0]:
		Goal = Goals.RELAX
	elif dice_roll < probabilities[0]+probabilities[1]:
		Goal = Goals.RELOCATE
	else:
		Goal = Goals.SHOOT_PLAYER

func _on_decision_timer_timeout():
		
	$Behaviours/Attacks/ShootStars.stop() 

	previous_goal = Goal
	choose_random_goal()
	
	if Goal == Goals.SHOOT_PLAYER:
		$Behaviours/Attacks/ShootStars.start()
	
	elif Goal == Goals.RELOCATE and mobile == true:
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
	
	$Behaviours/Attacks/ShootStars.stop()
	$CPUParticles2D.lifetime = 1.0
	$CPUParticles2D.emitting = true
	died.emit(name)
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
