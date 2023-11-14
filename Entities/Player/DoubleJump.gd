# initiate and execute double jump (somersault)
# can transition to ground (run, idle)

# hold vertical position for a moment, then accelerate up.

extends PlayerState

enum SubStates { HOVERING, SOMERSAULTING }
var SubState = SubStates.HOVERING

const double_jump_velocity_multiplier = 1.0


signal initiated_hover
signal initiated_somersault
signal landed

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	await owner.ready
	if player.has_method("_on_double_jump_hover_initiated"):
		initiated_hover.connect(player._on_double_jump_hover_initiated)
	if player.has_method("_on_double_jump_somersault_initiated"):
		initiated_somersault.connect(player._on_double_jump_somersault_initiated)
	if player.has_method("_on_landed"):
		landed.connect(player._on_landed)

func physics_update(delta):
	apply_gravity(delta)
	check_for_attack_requests()
	#check_for_jump_button_release()
	player.move_and_slide()
	land_if_possible()

func apply_gravity(delta):
	if SubState in [ SubStates.HOVERING, SubStates.SOMERSAULTING]:
		# Vertical movement.
		if player.velocity.y < 0: # going up:
			player.velocity.y += player.gravity * delta
		else: # going down (double accel):
			player.velocity.y += 2.0 * player.gravity * delta


func check_for_jump_button_release():
	if SubState == SubStates.HOVERING:
		if Input.is_action_just_released("jump"):
			# player released the jump button, so we can execute the somersault
			execute_somersault()
		

func check_for_attack_requests():
	if Input.is_action_just_pressed("strong_punch"):
		player.velocity.x = Input.get_axis("move_left", "move_right") * player.SPEED
		player.set_direction(sign(player.velocity.x))
		state_machine.transition_to("DescendingKick")
	elif Input.is_action_just_pressed("fast_punch"):
		player.velocity.x = Input.get_axis("move_left", "move_right") * player.SPEED
		player.set_direction(sign(player.velocity.x))
		state_machine.transition_to("Dash")


func enter(_msg := {}):
	super()
	initiate_hover()

func initiate_hover():
	player.velocity.y = -double_jump_velocity_multiplier * player.JUMP_VELOCITY
	SubState = SubStates.HOVERING
	initiated_hover.emit()

func execute_somersault():
	SubState = SubStates.SOMERSAULTING
	initiated_somersault.emit()


func land_if_possible():
	if player.velocity.y >= 0 and player.is_on_floor():
		state_machine.transition_to("Landing")

func exit():
	super()
	pass
	
func _on_player_animation_finished(anim_name):
	if anim_name == "somersault_initiate":
		execute_somersault()
	elif anim_name == "somersault_execute":
		state_machine.transition_to("Air", {"double_jumped" : true})
		
