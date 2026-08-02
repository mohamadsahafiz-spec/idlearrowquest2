class_name EnemyStats
extends Resource

@export var max_hp: float = 100.0
@export var movement_speed: float = 85.0
@export var attack: float = 10.0
@export var attack_speed: float = 1.0
@export var reward: int = 10

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
