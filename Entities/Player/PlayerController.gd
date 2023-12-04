# Player Controller for 2D action platformer
# move, jump, strong_punch, fast_punch, shoot, interact, etc.


extends CharacterBody2D


var SPEED = Globals.player_stats["speed"]
#var speed = SPEED # for state machine
var JUMP_VELOCITY = Globals.player_stats["jump_velocity"]

@onready var camera = $Lookahead/Camera2D
@onready var hud = $HUD
@onready var animation_player = $AnimationPlayer

var health_max = Globals.player_stats["max_health"]
var health = health_max
var temporary_health_bonus = 0

#@export var damage_defaults := {
#	"FastPunch":50,
#	"StrongPunch":100, # plus charge time
#	"DescendingKick":150,
#	"Dash":30 # dash was OP, becaus it offers useful mobility and damage
#}


var iframes : bool = false

var initializing : bool = true

@onready var state_machine = $StateMachine

var original_body_scale : Vector2
var original_sprite_position : Vector2

var last_fast_punch_animation : String

signal hit(attackPacket)
signal injured



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _enter_tree():
	initializing = true
	if StageManager.current_player == null:
		StageManager.current_player = self
		#$Lookahead/Camera2D.make_current()
	else:
		printerr("Too many player controllers already. Queuing_free.")
		printerr("But first. I'm in this node: " + owner.name)
		call_deferred("queue_free")

func _ready():
	
	hud.show()
	injured.connect(hud._on_player_hit)
	injured.connect(StageManager._on_damage_packet_processed)
	original_body_scale = $Body/CyberRoninSprites.scale
	original_sprite_position = $Body/CyberRoninSprites.position
	$AnimationPlayer.play("RESET")

	# wait for other scenes to get ready
	await get_tree().create_timer(0.3).timeout
	initializing = false
	
func orient_sprites_to_velocity():
	if abs(velocity.x) > 0:
		face(sign(velocity.x))
#		$Body.scale.x = sign(velocity.x) * original_body_scale.x
#		state_machine.scale.x = $Body.scale.x

func face(dir):
	$Body.scale.x = dir * original_body_scale.x
	state_machine.scale.x = dir
	
func get_last_known_direction():
	if $Body.scale.x > 0:
		return 1
	else:
		return -1


func _physics_process(_delta):
	if state_machine.state.name != "StrongPunch":
		orient_sprites_to_velocity()
	$Debug.global_rotation = 0.0 # for the state label
	if Input.is_action_just_pressed("debug"):
		initiate_debugging_protocol()
	elif Input.is_action_just_pressed("zoom_in"):
		zoom_camera(-1)
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_camera(1)
	

func play_run_animation():
	if $AnimationPlayer.current_animation != "run":
		$AnimationPlayer.play("run")


func play_jump_peak_animation():
	# wait for a signal from Air state
	# includes frames for falling.
	$AnimationPlayer.play("jump_peak")
	#$Body/CyberRoninSprites.play("jump_peak")

func play_fall_animation():
	$AnimationPlayer.play("fall")

func play_idle_animation():
	if $AnimationPlayer.current_animation != "idle":
		$AnimationPlayer.play("idle")


func play_somersault_animation(anim_name_surfix : String):
	# somersault_initiate or somersault_execute
	if $AnimationPlayer.current_animation != "somersault_" + anim_name_surfix:
		$AnimationPlayer.play("somersault_" + anim_name_surfix)
	

func reset_rotation():
	# hack for when state changes during a somersault.
	animation_player.play("RESET")

func initiate_debugging_protocol():
	zoom_camera(1)
	
	var upgrades = ["health", "speed", "damage_multiplier", "jump_velocity"]
	for upgrade in upgrades:
		Globals.player_stats[upgrade] = Globals.max_stats_upper_limits[upgrade]
	health = Globals.player_stats["max_health"]
	hud.update_health_display(health)
	
	#print("Player detected")
	#print("nodes in group Player: " + str(get_tree().get_nodes_in_group("Player")))
	
	#print("Canvas Nodes:")
	#var canvas_modulate_nodes = get_tree().get_root().find_children("anvas")
	#print(canvas_modulate_nodes)

	#print("World Nodes:")
	#var world_nodes = get_tree().get_root().find_children("orld")
	#print(world_nodes)

	

func zoom_camera(direction : int):
	#var camera = get_viewport().get_camera_2d()
	var zoom_levels = [ Vector2(3,3), Vector2(2, 2), Vector2(1.5, 1.5), Vector2(1.0,1.0), Vector2(0.75, 0.75), Vector2(0.5,0.5), Vector2(0.25, 0.25) ]
	var zoom_index = (zoom_levels.find(camera.zoom) + direction)%zoom_levels.size()
	camera.zoom = zoom_levels[zoom_index]
	

func reset_sprite_position():
	$Body/CyberRoninSprites.position = original_sprite_position


func detect_jump_through_platform() -> StaticBody2D:
	var jump_through_platform_detected
	var candidate_bodies = $PlatformDetector.get_overlapping_bodies()
	for candidate in candidate_bodies:
		if candidate.is_in_group("JumpThroughPlatforms") or "jump" in candidate.name.to_lower():
			jump_through_platform_detected = candidate
	return jump_through_platform_detected


func detect_moving_platform() -> StaticBody2D:
	var moving_platform_detected
	var candidate_bodies = $PlatformDetector.get_overlapping_bodies()
	for candidate in candidate_bodies:
		if candidate.is_in_group("MovingPlatforms"):
			moving_platform_detected = candidate
	return moving_platform_detected


func detect_npcs_underfoot():
	var npcs_detected = []
	var candidate_bodies = $PlatformDetector.get_overlapping_bodies()
	for candidate in candidate_bodies:
		if candidate.is_in_group("Enemies") or "npc" in candidate.name.to_lower():
			npcs_detected.push_back(candidate)
	return npcs_detected
	






#888888888888                                             88           88                                       
#     88                                                  ""    ,d     ""                                       
#     88                                                        88                                              
#     88  8b,dPPYba,  ,adPPYYba,  8b,dPPYba,   ,adPPYba,  88  MM88MMM  88   ,adPPYba,   8b,dPPYba,   ,adPPYba,  
#     88  88P'   "Y8  ""     `Y8  88P'   `"8a  I8[    ""  88    88     88  a8"     "8a  88P'   `"8a  I8[    ""  
#     88  88          ,adPPPPP88  88       88   `"Y8ba,   88    88     88  8b       d8  88       88   `"Y8ba,   
#     88  88          88,    ,88  88       88  aa    ]8I  88    88,    88  "8a,   ,a8"  88       88  aa    ]8I  
#     88  88          `"8bbdP"Y8  88       88  `"YbbdP"'  88    "Y888  88   `"YbbdP"'   88       88  `"YbbdP"'  	


func _on_animation_player_animation_finished(anim_name):
	#NOTE: this could be triggered after the next animation has started.
	
	# pass the info on to the state machine, so they can coordinate velocity, etc.
	if state_machine.state.has_method("_on_player_animation_finished"):
		state_machine.state._on_player_animation_finished(anim_name)


func _on_state_transitioned(_stateName):
	reset_sprite_position()


func _on_jumped(): # from Air state
	animation_player.play("jump_launch")

func _on_peak_amplitude_reached(): # from Air state
	play_jump_peak_animation()

func _on_started_fall_descent():
	play_fall_animation()

func _on_double_jump_hover_initiated(): # from Air state
	play_somersault_animation("initiate")

func _on_double_jump_somersault_initiated():
	play_somersault_animation("execute")
	
func _on_landed():
	$AnimationPlayer.play("land")

func _on_started_idling():
	$AnimationPlayer.play("idle")

func _on_started_running():
	$AnimationPlayer.play("run")
	
func _on_descending_kick_started():
# should animation calls come from the State machine or the player?
	if animation_player.has_animation("descending_kick"):
		animation_player.play("descending_kick")


func _on_dash_started():
	if animation_player.has_animation("dash"):
		animation_player.play("dash")





#  ,ad8888ba,                                    88                                
# d8"'    `"8b                                   88                         ,d     
#d8'                                             88                         88     
#88              ,adPPYba,   88,dPYba,,adPYba,   88,dPPYba,   ,adPPYYba,  MM88MMM  
#88             a8"     "8a  88P'   "88"    "8a  88P'    "8a  ""     `Y8    88     
#Y8,            8b       d8  88      88      88  88       d8  ,adPPPPP88    88     
# Y8a.    .a8P  "8a,   ,a8"  88      88      88  88b,   ,a8"  88,    ,88    88,    
#  `"Y8888Y"'    `"YbbdP"'   88      88      88  8Y"Ybbd8"'   `"8bbdP"Y8    "Y888  


func fast_punch(anim_name): # comes from $StateMachine/FastPunch
	if state_machine.state.name == "FastPunch":
		# play 3 animation sequence.
		if not "fast_punch" in animation_player.current_animation:
			last_fast_punch_animation = anim_name
			animation_player.play(anim_name)
			#$Body/CyberRoninSprites.play("fast_punch")


func _on_strong_punch_started(): # comes from $StateMachine/StrongPunch
	animation_player.play("strong_punch")
		

# moved to attack States
#func inflict_harm(body, damage: float = 10.0, knockback_magnitude : float = 1.0, uppercut: bool = false):
#	var attackPacket = AttackPacket.new()
#	attackPacket.recipient = body
#	attackPacket.damage = damage
#	attackPacket.impact_vector = self.global_position.direction_to(body.global_position)
#	# impactVector is normalized.. so we need knockback_magnitude to amplify it.
#	var up_force = 1.5
#	if uppercut: 
#		attackPacket.impact_vector += Vector2.UP * up_force
#	attackPacket.impact_vector *= knockback_magnitude
#	#var damageType = Globals.DamageTypes.IMPACT
#	attackPacket.knockback = (knockback_magnitude > 0.9)
#	attackPacket.damage_type = Globals.DamageTypes.IMPACT
#
#	if body.has_method("_on_hit"):
#		hit.connect(body._on_hit)
#		hit.emit(attackPacket)
#		hit.disconnect(body._on_hit)

	# StageManager also gets a copy of the attackPacket
	





#receive injury
func _on_hit(attackPacket : AttackPacket):
	if ( # a whole litany of exceptions
			initializing == true
			or iframes == true
			or state_machine.state.name in ["Dying", "Dead", "InTransit", "Dash", "DescendingKick"]
			or state_machine.state.name == "StrongPunch" and state_machine.state.stepping_back == true
			or state_machine.state.name == "StrongPunch" and state_machine.state.moving == true
		):
			return
	
	else:
		if attackPacket.damage_type == Globals.DamageTypes.ELECTRICAL:
			$Audio/HurtNoiseEnergy.play()
		elif attackPacket.damage_type == Globals.DamageTypes.IMPACT:
			$Audio/HurtNoiseImpact.play()
		health -= attackPacket.damage
		Globals.player_stats["health"] = health
		injured.emit(attackPacket)
		$IFrames.start()
		if attackPacket.knockback:
			velocity = attackPacket.impact_vector * attackPacket.knockback_speed
			if "spikes" in attackPacket.originator.name.to_lower():
				state_machine.transition_to("Air", {"do_jump": true, "involuntary": true})
		if health <= 0:
			print("health = " + str(health))
			begin_dying()
	
	
func begin_dying():
	state_machine.transition_to("Dying")
	animation_player.play("begin_dying")

func _on_iframes_started():
	iframes = true
	var hit_flash_material : Material = $Body/CyberRoninSprites.material
	hit_flash_material.set_shader_parameter("IFrames", true)
	
func _on_iframes_finished():
	iframes = false
	var hit_flash_material : Material = $Body/CyberRoninSprites.material
	hit_flash_material.set_shader_parameter("IFrames", false)

func _on_player_died():
	animation_player.play("die")
	
func _on_door_entered():
	state_machine.transition_to("InTransit")

func _on_door_exited():
	state_machine.transition_to("Idle")


func _pickable_picked_up(pickup_type):
	match pickup_type:
		Globals.PickupTypes.HEALTH:
			if Globals.player_stats["max_health"] < Globals.max_stats_upper_limits["health"]:
				Globals.player_stats["max_health"] += 10
			if health < Globals.player_stats["max_health"]:
				health += 10
			hud._on_player_picked_up_health()
		Globals.PickupTypes.DAMAGE:
			# this could get out of control, but it's fine for now
			if Globals.player_stats["damage_multiplier"] < Globals.max_stats_upper_limits["damage_multiplier"]:
				Globals.player_stats["damage_multiplier"] *= 1.15
#				for damage_type in Globals.player_damage_defaults.keys():
#					Globals.player_damage_defaults[damage_type] *= 1.25
		Globals.PickupTypes.SPEED:
			if Globals.player_stats["speed"] < Globals.max_stats_upper_limits["speed"]:
				Globals.player_stats["speed"] += 25
				SPEED = Globals.player_stats["speed"]
		Globals.PickupTypes.JUMP:
			if Globals.player_stats["jump_velocity"] < Globals.max_stats_upper_limits["jump_velocity"]:
				Globals.player_stats["jump_velocity"] += 25
				JUMP_VELOCITY = Globals.player_stats["jump_velocity"]
	hud._on_player_picked_up_powerup(pickup_type)

func _on_paused():
	state_machine.transition_to("Paused")

func _on_resume():
	state_machine.transition_to("Idle")

func _on_container_entered(containerNode):
	hud._on_container_entered(containerNode)

