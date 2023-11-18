## works like one-way teleporter
## a marker identifies the destination

extends Node2D

var directions = {
	"UP": Vector2.UP,
	"RIGHT": Vector2.RIGHT,
	"DOWN":Vector2.DOWN,
	"LEFT": Vector2.LEFT,
}     

var distance = 48

# Called when the node enters the scene tree for the first time.
func _ready():
	if directions.has(name):
		$Destination.global_position = global_position + directions[name] * distance




func _on_area_2d_body_entered(body):
	if "player" in body.name.to_lower():
		var tween = create_tween()
		tween.tween_property(body, "global_position", $Destination.global_position, 1.0)
		
		
