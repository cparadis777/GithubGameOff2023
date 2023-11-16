## Reusable behaviour for shooting a projectile
## Has it's own built in recoil and reload timers.
## Just call start() and stop()

extends Node2D

@export var bullet_scene = preload("res://Entities/Projectiles/bullet_basic.tscn")

enum States { INITIALIZING, PAUSED, READY, SHOOTING }
var State = States.INITIALIZING

@export var shots_per_magazine = 3
var current_shot = 0

signal shot_requested()

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReloadTimer.start()
	if owner.has_method("_on_shot_requested"):
		shot_requested.connect(owner._on_shot_requested)
	# temporary, until levels can activate props...
	activate()

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
	var spread = 16
	var random_miss = Vector2(randf_range(-spread, spread), randf_range(-spread, spread))
	owner.look_at(StageManager.current_player.global_position + random_miss)
	shoot()

func stop():
	State = States.PAUSED


func shoot():
	if State == States.SHOOTING:
		shot_requested.emit()
	
func launch_bullet():
	var newBullet = bullet_scene.instantiate()
	add_child(newBullet)
	newBullet.rotation = owner.rotation
	newBullet.global_position = global_position
	newBullet.activate(owner.transform.x)
	
	if current_shot >= shots_per_magazine-1:
		current_shot = 0
		$ReloadTimer.start()
	else:
		current_shot += 1
		$RecoilTimer.start()




func activate():
	State = States.READY

func _on_recoil_timer_timeout():
	if State == States.SHOOTING:
		shoot()

func _on_reload_timer_timeout():
	if State == States.SHOOTING:
		shoot()
