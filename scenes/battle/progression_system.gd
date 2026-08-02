class_name ProgressionSystem
extends Node

signal gold_changed(current_gold: int)
signal upgrade_applied(type: String, level: int)

@export var gold: int = 0

var attack_level: int = 1
var speed_level: int = 1
var crit_level: int = 1
var hp_level: int = 1

var base_attack: float = 0.0
var base_max_hp: float = 0.0
var base_attack_speed: float = 0.0
var base_critical_chance: float = 0.0
var base_captured: bool = false

const MAX_SPEED: float = 4.0
const MAX_CRIT: float = 0.80

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func get_attack_cost() -> int:
	return 10 + (attack_level - 1) * 8

func get_speed_cost() -> int:
	return 15 + (speed_level - 1) * 12

func get_crit_cost() -> int:
	return 20 + (crit_level - 1) * 15

func get_hp_cost() -> int:
	return 12 + (hp_level - 1) * 10

func capture_base_stats(defender: DefenderPlaceholder) -> void:
	if defender != null and defender.stats != null and not base_captured:
		base_attack = defender.base_attack if defender.base_attack > 0.0 else defender.stats.attack
		base_max_hp = defender.base_max_hp if defender.base_max_hp > 0.0 else defender.stats.max_hp
		base_attack_speed = defender.base_attack_speed if defender.base_attack_speed > 0.0 else defender.stats.attack_speed
		base_critical_chance = defender.base_critical_chance if defender.base_critical_chance > 0.0 else defender.stats.critical_chance
		base_captured = true

func get_attack_value(level: int = -1) -> float:
	var l: int = attack_level if level < 0 else level
	return base_attack + float(l - 1) * 3.0

func get_speed_value(level: int = -1) -> float:
	var raw_l: int = speed_level if level < 0 else level
	if raw_l <= 20:
		return base_attack_speed + float(raw_l - 1) * 0.10
	else:
		var base_20: float = base_attack_speed + 19.0 * 0.10
		var extra: float = float(raw_l - 20) * 0.10
		return base_20 + (extra / (1.0 + extra * 0.15))

func get_crit_value(level: int = -1) -> float:
	var l: int = crit_level if level < 0 else level
	return base_critical_chance + float(l - 1) * 0.02

func get_hp_value(level: int = -1) -> float:
	var l: int = hp_level if level < 0 else level
	return base_max_hp + float(l - 1) * 25.0

func is_speed_maxed() -> bool:
	return false

static func calculate_combat_power(atk: float, spd: float, crit: float, hp: float) -> int:
	return int(round(atk * spd * (1.0 + crit * 0.5) + hp * 0.2))

func get_combat_power(defender: DefenderPlaceholder) -> int:
	if defender == null or defender.stats == null:
		return 0
	return calculate_combat_power(
		defender.stats.attack,
		defender.stats.attack_speed,
		defender.stats.critical_chance,
		defender.stats.max_hp
	)

func is_crit_maxed() -> bool:
	return false

func can_buy_attack() -> bool:
	return gold >= get_attack_cost()

func can_buy_speed() -> bool:
	return gold >= get_speed_cost()

func can_buy_crit() -> bool:
	return gold >= get_crit_cost()

func can_buy_hp() -> bool:
	return gold >= get_hp_cost()

func buy_attack() -> bool:
	var cost: int = get_attack_cost()
	if gold >= cost:
		gold -= cost
		attack_level += 1
		gold_changed.emit(gold)
		upgrade_applied.emit("attack", attack_level)
		return true
	return false

func buy_speed() -> bool:
	var cost: int = get_speed_cost()
	if gold >= cost:
		gold -= cost
		speed_level += 1
		gold_changed.emit(gold)
		upgrade_applied.emit("speed", speed_level)
		return true
	return false

func buy_crit() -> bool:
	var cost: int = get_crit_cost()
	if gold >= cost:
		gold -= cost
		crit_level += 1
		gold_changed.emit(gold)
		upgrade_applied.emit("crit", crit_level)
		return true
	return false

func buy_hp() -> bool:
	var cost: int = get_hp_cost()
	if gold >= cost:
		gold -= cost
		hp_level += 1
		gold_changed.emit(gold)
		upgrade_applied.emit("hp", hp_level)
		return true
	return false

func reset_progression() -> void:
	gold = 0
	attack_level = 1
	speed_level = 1
	crit_level = 1
	hp_level = 1
	gold_changed.emit(gold)
	upgrade_applied.emit("reset", 1)

func apply_to_defender(defender: DefenderPlaceholder, equipment_system: EquipmentSystem = null, is_overdrive_active: bool = false) -> void:
	if defender == null or defender.stats == null:
		return

	var m_id: String = defender.maid_id
	var eq_atk: float = equipment_system.get_maid_attack_bonus(m_id) if equipment_system != null else 0.0
	var eq_spd: float = equipment_system.get_maid_speed_bonus(m_id) if equipment_system != null else 0.0
	var eq_crit: float = equipment_system.get_maid_crit_bonus(m_id) if equipment_system != null else 0.0
	var eq_hp: float = equipment_system.get_maid_hp_bonus(m_id) if equipment_system != null else 0.0

	var old_max_hp: float = defender.max_hp

	if m_id == "001":
		capture_base_stats(defender)
		defender.stats.attack = get_attack_value() + eq_atk
		var total_speed: float = get_speed_value() + eq_spd
		if is_overdrive_active:
			total_speed *= 2.0
		defender.stats.attack_speed = total_speed
		defender.stats.critical_chance = get_crit_value() + eq_crit
		defender.stats.max_hp = get_hp_value() + eq_hp
	else:
		defender.stats.attack = defender.base_attack + eq_atk
		var total_speed: float = defender.base_attack_speed + eq_spd
		if is_overdrive_active:
			total_speed *= 2.0
		defender.stats.attack_speed = total_speed
		defender.stats.critical_chance = defender.base_critical_chance + eq_crit
		defender.stats.max_hp = defender.base_max_hp + eq_hp

	var new_max_hp: float = defender.stats.max_hp
	defender.max_hp = new_max_hp
	var delta_hp: float = new_max_hp - old_max_hp
	if delta_hp > 0.0:
		defender.current_hp += delta_hp
	defender.current_hp = clampf(defender.current_hp, 0.0, new_max_hp)
	defender.hp_changed.emit(defender.current_hp, defender.max_hp)
	defender.queue_redraw()

