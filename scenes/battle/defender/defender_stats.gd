class_name DefenderStats
extends Resource

@export var attack: float = 15.0
@export var attack_speed: float = 1.25
@export var critical_chance: float = 0.05
@export var critical_damage: float = 1.5
@export var range: float = 240.0

func get_fire_cooldown() -> float:
	return 1.0 / maxf(0.01, attack_speed)
