extends PlayerState

var sequence_animations = ["fast_punch_1","fast_punch_2","fast_punch_3"]
var punch_num_in_sequence = 0
var damage

@export var time_before_sequence_resets : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await owner.ready 
	damage = player.damage_defaults[name]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	move_forward(delta)
	
func move_forward(_delta):
	player.velocity.x = player.SPEED * 0.33 * player.get_last_known_direction()
	player.move_and_slide()
	

func enter(_msg := {}) -> void:
	$UnbrokenSequenceTimer.stop() # start over
	player.fast_punch(sequence_animations[punch_num_in_sequence])
	punch_num_in_sequence = (punch_num_in_sequence + 1) % sequence_animations.size() 
	$UnbrokenSequenceTimer.start(time_before_sequence_resets)
	
	
func exit():
	super()
	$HurtBox/FastCollisionShape.disabled = true
	
func _on_player_animation_finished(anim_name):
	if anim_name in sequence_animations:
		if abs(Input.get_axis("move_left", "move_right")) > 0:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")


func _on_unbroken_sequence_timer_timeout():
	punch_num_in_sequence = 0


func _on_hurt_box_body_entered(body):
	if body.is_in_group("Enemies") or body.is_in_group("Kickables"):
		if state_machine.state.name == "FastPunch":
			var knockback_magnitude = punch_num_in_sequence
			var uppercut = punch_num_in_sequence == 2
			player.inflict_harm(body, 10, knockback_magnitude, uppercut)
			$ImpactAudio.get_child(punch_num_in_sequence).play()

