class_name DefenderStats
extends Resource

@export var attack: float = 15.0
@export var attack_speed: float = 1.25
@export var critical_chance: float = 0.05
@export var critical_damage: float = 1.5
@export var range: float = 240.0

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
	var is_crit: bool = randf() < maxf(0.0, critical_chance)
	var base_dmg: float = get_attack_damage()
	var final_dmg: float = base_dmg * (get_critical_damage_multiplier() if is_crit else 1.0)
	return {
		"damage": final_dmg,
		"is_critical": is_crit
	}
