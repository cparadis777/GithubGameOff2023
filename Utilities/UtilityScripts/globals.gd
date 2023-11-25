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

var difficulty : DifficultyScales = DifficultyScales.TRIVIAL


var player_stats = {
	"max_health" : 50, # 1 heart = 10 points
	"speed" : 150,
	"jump_velocity": 375,
	"damage_multiplier" : 1.0,
}

var max_stats_upper_limits = {
	"health" : 200,
	"speed" : 500,
	"damage_multiplier" : 5.0,
	"jump_velocity" : 300,
}

@export var player_damage_defaults := {
	"FastPunch":50,
	"StrongPunch":100, # plus charge time
	"DescendingKick":150,
	"Dash":30 # dash was OP, becaus it offers useful mobility and damage
}
