extends Node

enum DifficultyScales {
	TRIVIAL,
	SIMPLE,
	BABY,
	EASY,
	MODERATE,
	AVERAGE,
	CHALLENGING,
	TOUGH,
	HARD,
	DEMANDING,
	INTENSE,
	FORMIDABLE,
	STRENUOUS,
	ARDUOUS,
	RIGOROUS,
	BRUTAL,
	HARROWING,
	HERCULEAN,
	INSANE,
	HARDCORE
}

enum Graphics { LOW, HIGH }
enum DamageTypes { WEAK_MELEE, STRONG_MELEE, IMPACT, PIERCE, FIRE, POISON, ELECTRICAL, BLEED }
enum PickupTypes { HEALTH, DAMAGE, SPEED, JUMP }

var difficulty : DifficultyScales = DifficultyScales.AVERAGE
var scale_weight : float = 0.0
var max_weight : float = 1000.0

var player_stats = {
	"max_health" : 100, # 1 heart = 10 points
	"speed" : 150,
	"jump_velocity": 375,
	"damage_multiplier" : 1.0,
	"completed_levels" : [] # at end of game, it'll look like [1,2]
}

var max_stats_upper_limits = {
	"health" : 200,
	"speed" : 500,
	"damage_multiplier" : 5.0,
	"jump_velocity" : 600,
} 

@export var player_damage_defaults := {
	"FastPunch":50,
	"StrongPunch":80, # time multiples for charge time
	"DescendingKick":150,
	"Dash":30 # dash was OP, becaus it offers useful mobility and damage
}

func set_difficulty_based_on_weight():
	# there's 20 points of difficulty.
	difficulty = int(clamp(scale_weight / max_weight, 0, 19) * DifficultyScales.keys().size()) as DifficultyScales
	print("Setting difficulty based on ", scale_weight , " out of ", max_weight)
	print(DifficultyScales.keys()[difficulty])
