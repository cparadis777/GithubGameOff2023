extends Node2D
enum container_types { BENGAL, ICE, EAGLE }
@export var type : container_types = container_types.BENGAL
var textures = {
	container_types.BENGAL: preload("res://art/low_res_containers/shipping_container_bengal_security-LOWRES.png"),
	container_types.ICE: preload("res://art/low_res_containers/shipping_container_ice_and_freezy_LOWRES.png"),
	container_types.EAGLE : preload("res://art/low_res_containers/shipping_container_ill_eagle-LOWRES.png"),
} 

# Called when the node enters the scene tree for the first time.
func _ready():
	$RigidBody2D/Left.texture = textures[type]
	$RigidBody2D2/Right.texture = textures[type]
	


