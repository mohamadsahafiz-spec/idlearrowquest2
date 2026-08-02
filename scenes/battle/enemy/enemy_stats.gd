class_name EnemyStats
extends Resource

enum Tier {
	NORMAL,
	STRONG,
	ELITE,
	BOSS
}

@export var tier: Tier = Tier.NORMAL
@export var max_hp: float = 100.0
@export var movement_speed: float = 85.0
@export var attack: float = 10.0
@export var attack_speed: float = 1.0
@export var reward: int = 10

static func create_for_tier(target_tier: Tier) -> EnemyStats:
	var stats: EnemyStats = EnemyStats.new()
	stats.tier = target_tier
	match target_tier:
		Tier.NORMAL:
			stats.max_hp = 100.0
			stats.movement_speed = 85.0
			stats.attack = 10.0
			stats.attack_speed = 1.0
			stats.reward = 10
		Tier.STRONG:
			stats.max_hp = 220.0
			stats.movement_speed = 85.0
			stats.attack = 18.0
			stats.attack_speed = 1.0
			stats.reward = 25
		Tier.ELITE:
			stats.max_hp = 500.0
			stats.movement_speed = 85.0
			stats.attack = 35.0
			stats.attack_speed = 1.0
			stats.reward = 60
		Tier.BOSS:
			stats.max_hp = 1500.0
			stats.movement_speed = 75.0
			stats.attack = 75.0
			stats.attack_speed = 0.8
			stats.reward = 200
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
