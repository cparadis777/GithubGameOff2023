extends PlayerState

signal died()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await owner.ready
	$Timer.timeout.connect(_on_death_timer_timeout)

	died.connect(player._on_player_died)

func enter(_msg := {}) -> void:
	$CPUParticles2D.emitting = true
	$Timer.start()
	
func exit():
	pass

func _on_death_timer_timeout():
	died.emit()
	state_machine.transition_to("Dead")

