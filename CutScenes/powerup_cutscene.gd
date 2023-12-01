extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func activate(powerupType : Globals.PickupTypes):
	var type_str = Globals.PickupTypes.keys()[powerupType]
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.1, 0.25)
	#Engine.time_scale = 0.25
	$AnimationPlayer.play("slide_across")
	$Panel/PowerupIcon.play(type_str)
	$Panel/PowerupType.text = type_str


func _on_animation_player_animation_finished(_anim_name):
	Engine.time_scale = 1.0
	queue_free()
	
func speed_up():
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.1)
	
