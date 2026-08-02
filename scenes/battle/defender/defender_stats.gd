class_name DefenderStats
extends Resource

@export var max_hp: float = 100.0
@export var attack: float = 15.0
@export var attack_speed: float = 1.25
@export var critical_chance: float = 0.05
@export var critical_damage: float = 1.5
@export var range: float = 240.0

func get_max_hp() -> float:
	return max_hp

func get_fire_cooldown() -> float:
	return 1.0 / maxf(0.01, attack_speed)

func get_attack_damage() -> float:
	return attack

func get_attack_range() -> float:
	return range

func get_critical_chance() -> float:
	return critical_chance

func get_critical_damage_multiplier() -> float:
	return critical_damage

func calculate_hit_damage() -> Dictionary:
	var base_dmg: float = get_attack_damage()
	var chance: float = maxf(0.0, critical_chance)
	var mult: float = 1.0
	var is_crit: bool = false

	while chance > 0.0:
		if randf() < minf(1.0, chance):
			mult += (critical_damage - 1.0)
			is_crit = true
		chance -= 1.0

	var final_dmg: float = base_dmg * mult
	return {
		"damage": final_dmg,
		"is_critical": is_crit
	}
