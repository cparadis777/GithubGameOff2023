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

var user_prefs = {
	"difficulty" : DifficultyScale.TRIVIAL,
}

var player_stats = {}


