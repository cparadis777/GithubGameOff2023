# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name PlayerState
extends EntityState

# Typed reference to the player node.
var player: CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	player = owner as CharacterBody2D
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(player != null)

func sync_motion_to_platforms(_delta):
	var potential_platforms = player.get_node("PlatformDetector").get_overlapping_bodies()
	for potential_platform in potential_platforms:
		if potential_platform != null and potential_platform.is_in_group("MovingPlatforms"):
			if potential_platform.owner.get("velocity"):
				player.velocity.y = potential_platform.owner.velocity.y

func apply_gravity(delta):
	if not player.is_on_floor(): # all states
		player.velocity.y += gravity * delta
