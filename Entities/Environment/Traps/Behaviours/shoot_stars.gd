## Reusable behaviour for shooting a projectile
## Has it's own built in recoil and reload timers.
## Just call start() and stop()

extends Node2D

@export var enabled : bool = true
@export var bullet_scene = preload("res://Entities/Projectiles/bullet_basic.tscn")
@export var horizontal_only : bool = false
@export var bad_aim_distance : float = 16.0
@export var bullet_jitter : float = 0.15
@export var free_rotate : bool = true
@export var reload_time : float = 2.5

enum States { INITIALIZING, PAUSED, READY, SHOOTING }
var State = States.INITIALIZING

@export var shots_per_magazine = 3
var current_shot = 0

signal shot_requested()

# Called when the node enters the scene tree for the first time.
func _ready():
	$CPUParticles2D.emitting = false
	if owner.has_method("_on_shot_requested"):
		shot_requested.connect(owner._on_shot_requested)
	# temporary, until levels can activate props...
	if enabled:
		activate()


func activate():
	State = States.READY
	$ReloadTimer.start()


func activate_new_state(value):
	if value == States.SHOOTING:
		if $RecoilTimer.is_stopped() and $ReloadTimer.is_stopped():
			start()
		else:
			$RecoildTimer.stop()
			$ReloadTimer.stop()

func start():
	State = States.SHOOTING
	# locate the player and point near them.
	var spread = bad_aim_distance
	var random_miss = Vector2(randf_range(-spread, spread), randf_range(-spread, spread))
	if free_rotate and not horizontal_only:
		owner.look_at(StageManager.current_player.global_position + random_miss)
	shoot()

func stop():
	State = States.PAUSED


func shoot():
	if State == States.SHOOTING:
		shot_requested.emit()
		# note: we're expecting the animation to call for launch_bullet()
	
func launch_bullet():
	$CPUParticles2D.emitting = false
	var newBullet = bullet_scene.instantiate()
	add_child(newBullet)
	newBullet.rotation = owner.rotation
	newBullet.global_position = global_position
	var jitter = randf_range(-bullet_jitter, bullet_jitter)
	
	if horizontal_only:
		newBullet.activate(Vector2(owner.direction, 0).rotated(jitter)) # shoot left and right only
	else:
		newBullet.activate(owner.transform.x.rotated(jitter)) # shoot in 360 degrees
		
	
	if current_shot >= shots_per_magazine-1:
		current_shot = 0
		
		if randf() > 0.1: # once in a while, just keep shooting.. mix it up so we're not so predictable
			$ReloadTimer.set_wait_time(reload_time * randf_range(0.8, 1.25))
			$ReloadTimer.start()
		else: 
			_on_reload_timer_timeout() 
	else:
		current_shot += 1
		$RecoilTimer.start()


func charge_weapon():
	$CPUParticles2D.emitting = true



func _on_recoil_timer_timeout():
	if State == States.SHOOTING:
		shoot()

func _on_reload_timer_timeout():
	if State == States.SHOOTING:
		shoot()
