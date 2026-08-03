class_name EnemyStats
extends Resource

enum Tier {
	NORMAL,
	STRONG,
	ELITE,
	BOSS
}

@export var tier: Tier = Tier.NORMAL
@export var enemy_name: String = ""
@export var max_hp: float = 100.0
@export var movement_speed: float = 85.0
@export var attack: float = 10.0
@export var attack_speed: float = 1.0
@export var reward: int = 10
@export var element: String = "fire"

static func create_for_tier(target_tier: Tier, stage_level: int = 1, world_id: int = 1) -> EnemyStats:
	var stats: EnemyStats = EnemyStats.new()
	stats.tier = target_tier
	var cum_stages: int = WorldRegistry.get_cumulative_stages_before(world_id)
	var global_stage: int = cum_stages + stage_level
	var world_scale: float = 1.0 + float(world_id - 1) * 0.45
	var stage_scale: float = maxf(0.0, float(stage_level - 1)) * 0.22
	var global_scale: float = pow(float(global_stage - 1) * 0.012, 1.25)
	var scale_mult: float = (1.0 + stage_scale) * world_scale + global_scale

	var elem_pool: Array[String] = ["fire", "earth"]
	if world_id == 2:
		elem_pool = ["earth", "water"]
	elif world_id == 3:
		elem_pool = ["water", "wind"]
	elif world_id == 4:
		elem_pool = ["wind", "fire"]
	elif world_id >= 5:
		elem_pool = ["fire", "water", "earth", "wind"]
	stats.element = elem_pool[randi() % elem_pool.size()]
	match target_tier:
		Tier.NORMAL:
			stats.max_hp = 100.0 * scale_mult
			stats.movement_speed = 85.0
			stats.attack = 10.0 * scale_mult
			stats.attack_speed = 1.0
			stats.reward = int(10.0 * scale_mult)
		Tier.STRONG:
			stats.max_hp = 220.0 * scale_mult
			stats.movement_speed = 85.0
			stats.attack = 18.0 * scale_mult
			stats.attack_speed = 1.0
			stats.reward = int(25.0 * scale_mult)
		Tier.ELITE:
			stats.max_hp = 500.0 * scale_mult
			stats.movement_speed = 85.0
			stats.attack = 35.0 * scale_mult
			stats.attack_speed = 1.0
			stats.reward = int(60.0 * scale_mult)
		Tier.BOSS:
			stats.max_hp = 1500.0 * scale_mult
			stats.movement_speed = 75.0
			stats.attack = 75.0 * scale_mult
			stats.attack_speed = 0.8
			stats.reward = int(200.0 * scale_mult)
	return stats

func get_max_hp() -> float:
	return max_hp

func get_movement_speed() -> float:
	return movement_speed

func get_reward() -> int:
	return reward

func get_attack_damage() -> float:
	return attack

func get_attack_speed() -> float:
	return attack_speed

func get_attack_cooldown() -> float:
	return 1.0 / maxf(0.01, attack_speed)

func get_tier_name() -> String:
	match tier:
		Tier.STRONG:
			return "Strong"
		Tier.ELITE:
			return "Elite"
		Tier.BOSS:
			return "Boss"
		_:
			return "Normal"

func get_tier_color() -> Color:
	match tier:
		Tier.STRONG:
			return Color(0.95, 0.55, 0.15, 1.0)
		Tier.ELITE:
			return Color(0.75, 0.25, 0.95, 1.0)
		Tier.BOSS:
			return Color(0.85, 0.12, 0.2, 1.0)
		_:
			return Color(0.95, 0.25, 0.25, 1.0)

func get_tier_outline_color() -> Color:
	match tier:
		Tier.STRONG:
			return Color(1.0, 0.85, 0.5, 0.95)
		Tier.ELITE:
			return Color(0.9, 0.7, 1.0, 0.95)
		Tier.BOSS:
			return Color(1.0, 0.85, 0.2, 1.0)
		_:
			return Color(1.0, 0.85, 0.85, 0.9)

func get_tier_radius_multiplier() -> float:
	match tier:
		Tier.STRONG:
			return 1.25
		Tier.ELITE:
			return 1.55
		Tier.BOSS:
			return 2.2
		_:
			return 1.0
