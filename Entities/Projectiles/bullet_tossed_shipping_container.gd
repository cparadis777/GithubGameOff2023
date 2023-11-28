extends "res://Entities/Projectiles/BulletBasic.gd"

enum container_types { BENGAL, ICE, EAGLE }
@export var types : container_types = container_types.BENGAL
var textures = {
	container_types.BENGAL: preload("res://art/low_res_containers/shipping_container_bengal_security-LOWRES.png"),
	container_types.ICE: preload("res://art/low_res_containers/shipping_container_ice_and_freezy_LOWRES.png"),
	container_types.EAGLE : preload("res://art/low_res_containers/shipping_container_ill_eagle-LOWRES.png"),
} 
var type : container_types

# Called when the node enters the scene tree for the first time.
func _ready():
	type = container_types.values().pick_random()
	$ContainerExteriorSprite.texture = textures[type]


func _on_body_entered(body):
	#super(body) # cause damage to player
	if body.is_in_group("Player"):
		# crack open and spawn enemies
		spawn_pieces()
		
func spawn_pieces():
	var pieces = preload("res://Entities/Projectiles/broken_container_pieces.tscn").instantiate()
	pieces.type = type
	get_tree().get_root().call_deferred("add_child", pieces)
	pieces.set_deferred("global_position", global_position)
	pieces.set_deferred("global_rotation", global_rotation)
	
