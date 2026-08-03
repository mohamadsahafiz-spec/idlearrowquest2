class_name SkillSystem
extends Node2D

signal skill_state_changed()
signal meteor_impact()

const SKILL_CATALOG: Dictionary = {
	"fireball": {
		"id": "fireball", "name": "Fireball", "element": "fire", "rarity": "common",
		"base_power": 80.0, "base_radius": 35.0, "base_cd": 8.0, "description": "Single fiery blast."
	},
	"firewall": {
		"id": "firewall", "name": "Firewall", "element": "fire", "rarity": "uncommon",
		"base_power": 120.0, "base_radius": 45.0, "base_cd": 12.0, "description": "Blazing flame barrier."
	},
	"meteor": {
		"id": "meteor", "name": "Meteor", "element": "fire", "rarity": "mythic",
		"base_power": 350.0, "base_radius": 75.0, "base_cd": 25.0, "description": "Cataclysmic meteor drop."
	},
	"water_arrows": {
		"id": "water_arrows", "name": "Water Arrows", "element": "water", "rarity": "common",
		"base_power": 75.0, "base_radius": 30.0, "base_cd": 6.0, "description": "Rapid water projectiles."
	},
	"tidal_wave": {
		"id": "tidal_wave", "name": "Tidal Wave", "element": "water", "rarity": "epic",
		"base_power": 220.0, "base_radius": 60.0, "base_cd": 18.0, "description": "Crushing wave surge."
	},
	"whirlpool": {
		"id": "whirlpool", "name": "Whirlpool", "element": "water", "rarity": "legendary",
		"base_power": 280.0, "base_radius": 65.0, "base_cd": 20.0, "description": "Swirling vortex."
	},
	"stone_spikes": {
		"id": "stone_spikes", "name": "Stone Spikes", "element": "earth", "rarity": "common",
		"base_power": 90.0, "base_radius": 32.0, "base_cd": 7.0, "description": "Sharp earthen spikes."
	},
	"boulder_crash": {
		"id": "boulder_crash", "name": "Boulder Crash", "element": "earth", "rarity": "rare",
		"base_power": 160.0, "base_radius": 50.0, "base_cd": 14.0, "description": "Giant falling rock."
	},
	"earthquake": {
		"id": "earthquake", "name": "Earthquake", "element": "earth", "rarity": "mythic",
		"base_power": 380.0, "base_radius": 85.0, "base_cd": 30.0, "description": "Violent ground quake."
	},
	"wind_blades": {
		"id": "wind_blades", "name": "Wind Blades", "element": "wind", "rarity": "uncommon",
		"base_power": 110.0, "base_radius": 40.0, "base_cd": 9.0, "description": "Razor gale slices."
	},
	"cyclone_burst": {
		"id": "cyclone_burst", "name": "Cyclone Burst", "element": "wind", "rarity": "epic",
		"base_power": 210.0, "base_radius": 55.0, "base_cd": 16.0, "description": "Explosive gust burst."
	},
	"tornado": {
		"id": "tornado", "name": "Tornado", "element": "wind", "rarity": "legendary",
		"base_power": 300.0, "base_radius": 70.0, "base_cd": 22.0, "description": "Raging twister."
	}
}

const MAX_SLOTS: int = 6

var unlocked_skills: Dictionary = {
	"fireball": {"level": 1, "duplicates": 0},
	"water_arrows": {"level": 1, "duplicates": 0},
	"stone_spikes": {"level": 1, "duplicates": 0}
}

var equipped_slots: Array[String] = [
	"fireball",
	"water_arrows",
	"stone_spikes",
	"",
	"",
	""
]

var slot_cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var slot_autos: Array[bool] = [false, false, false, false, false, false]
var global_auto_skills: bool = true

var defender: DefenderPlaceholder = null
var enemies_container: Node2D = null
var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null

var active_effects: Array[Dictionary] = []

# Legacy stubs / properties
var meteor_cooldown: float:
	get: return slot_cooldowns[5] if slot_cooldowns.size() > 5 else 0.0
	set(val):
		if slot_cooldowns.size() > 5: slot_cooldowns[5] = val
var meteor_auto: bool:
	get: return slot_autos[5] if slot_autos.size() > 5 else false
	set(val):
		if slot_autos.size() > 5: slot_autos[5] = val

var freeze_cooldown: float = 0.0
var freeze_active_timer: float = 0.0
var freeze_auto: bool = false
var overdrive_cooldown: float = 0.0
var overdrive_active_timer: float = 0.0
var overdrive_auto: bool = false

func is_freeze_active() -> bool: return false
func is_overdrive_active() -> bool: return false
func is_meteor_ready() -> bool: return is_slot_ready(5)
func is_freeze_ready() -> bool: return false
func is_overdrive_ready() -> bool: return false
func on_enemy_spawned(_enemy: EnemyPlaceholder = null) -> void: pass

static func get_elemental_multiplier(skill_elem: String, target_elem: String) -> float:
	if skill_elem == target_elem or target_elem == "neutral" or target_elem.is_empty():
		return 1.0
	match skill_elem:
		"fire":
			if target_elem == "wind": return 1.5
			if target_elem == "water": return 0.6
		"water":
			if target_elem == "fire": return 1.5
			if target_elem == "earth": return 0.6
		"earth":
			if target_elem == "water": return 1.5
			if target_elem == "wind": return 0.6
		"wind":
			if target_elem == "earth": return 1.5
			if target_elem == "fire": return 0.6
	return 1.0

func get_unlocked_slot_count() -> int:
	var w: int = stage_system.current_world if stage_system != null else 1
	if w <= 1: return 3
	elif w == 2: return 4
	elif w == 3: return 5
	else: return 6

func get_skill_effective_stats(skill_id: String) -> Dictionary:
	var def: Dictionary = SKILL_CATALOG.get(skill_id, {})
	if def.is_empty(): return {}
	var unl: Dictionary = unlocked_skills.get(skill_id, {"level": 1, "duplicates": 0})
	var lvl: int = int(unl.get("level", 1))
	var pow_mult: float = 1.0 + (lvl - 1) * 0.15
	var rad_mult: float = 1.0 + (lvl - 1) * 0.05
	var cd_mult: float = maxf(0.4, 1.0 - (lvl - 1) * 0.03)
	return {
		"id": skill_id,
		"name": def.get("name", ""),
		"element": def.get("element", "fire"),
		"rarity": def.get("rarity", "common"),
		"level": lvl,
		"duplicates": int(unl.get("duplicates", 0)),
		"power": float(def.get("base_power", 100.0)) * pow_mult,
		"radius": float(def.get("base_radius", 40.0)) * rad_mult,
		"cooldown": maxf(1.5, float(def.get("base_cd", 10.0)) * cd_mult)
	}

func add_skill_or_duplicate(skill_id: String) -> void:
	if not SKILL_CATALOG.has(skill_id): return
	if unlocked_skills.has(skill_id):
		var d: Dictionary = unlocked_skills[skill_id]
		var dups: int = int(d.get("duplicates", 0)) + 1
		d["duplicates"] = dups
		d["level"] = 1 + int(dups / 2)
	else:
		unlocked_skills[skill_id] = {"level": 1, "duplicates": 0}
	skill_state_changed.emit()

func equip_skill_to_slot(slot_idx: int, skill_id: String) -> bool:
	if slot_idx < 0 or slot_idx >= MAX_SLOTS: return false
	if not skill_id.is_empty() and not unlocked_skills.has(skill_id): return false
	equipped_slots[slot_idx] = skill_id
	skill_state_changed.emit()
	return true

func is_slot_ready(slot_idx: int) -> bool:
	if slot_idx < 0 or slot_idx >= get_unlocked_slot_count(): return false
	var sk_id: String = equipped_slots[slot_idx]
	if sk_id.is_empty(): return false
	return slot_cooldowns[slot_idx] <= 0.0

func toggle_slot_auto(slot_idx: int) -> void:
	if slot_idx >= 0 and slot_idx < MAX_SLOTS:
		slot_autos[slot_idx] = not slot_autos[slot_idx]
		skill_state_changed.emit()

func toggle_auto(skill_name: String) -> void:
	if skill_name == "meteor":
		toggle_slot_auto(5)
	else:
		for i in range(MAX_SLOTS):
			if equipped_slots[i] == skill_name:
				toggle_slot_auto(i)

func trigger_slot(slot_idx: int) -> bool:
	if not is_slot_ready(slot_idx): return false
	var sk_id: String = equipped_slots[slot_idx]
	var eff: Dictionary = get_skill_effective_stats(sk_id)
	if eff.is_empty(): return false

	slot_cooldowns[slot_idx] = float(eff.get("cooldown", 10.0))
	_execute_skill(sk_id, eff)
	skill_state_changed.emit()
	return true

func trigger_skill(skill_name: String) -> bool:
	if skill_name == "meteor":
		return trigger_slot(5)
	for i in range(get_unlocked_slot_count()):
		if equipped_slots[i] == skill_name and is_slot_ready(i):
			return trigger_slot(i)
	return false

func can_auto_trigger() -> bool:
	if not global_auto_skills:
		return false
	if defender == null or not is_instance_valid(defender) or defender.current_hp <= 0.0:
		return false
	if stage_system != null:
		if stage_system.is_progression_interrupted:
			return false
		if stage_system.state != StageSystem.State.WAVE_ACTIVE and stage_system.state != StageSystem.State.BOSS_ACTIVE:
			return false
	return true

func _process(delta: float) -> void:
	var state_changed: bool = false
	var active_slots: int = get_unlocked_slot_count()

	for i in range(active_slots):
		if slot_cooldowns[i] > 0.0:
			slot_cooldowns[i] = maxf(0.0, slot_cooldowns[i] - delta)
			state_changed = true

	_update_active_effects(delta)

	if can_auto_trigger() and _has_active_enemies():
		for i in range(active_slots):
			if is_slot_ready(i):
				trigger_slot(i)

	if state_changed:
		skill_state_changed.emit()

func _has_active_enemies() -> bool:
	if enemies_container == null: return false
	for child in enemies_container.get_children():
		if child is EnemyPlaceholder and is_instance_valid(child) and not child.is_dead:
			return true
	return false

func _find_target_center() -> Vector2:
	if enemies_container == null: return Vector2(270, 260)
	var total_pos: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in enemies_container.get_children():
		if child is EnemyPlaceholder and is_instance_valid(child) and not child.is_dead:
			total_pos += child.position
			count += 1
	return (total_pos / float(count)) if count > 0 else Vector2(270, 260)

func _execute_skill(skill_id: String, eff: Dictionary) -> void:
	var target_pos: Vector2 = _find_target_center()
	var elem: String = eff.get("element", "fire")
	var rad: float = float(eff.get("radius", 40.0))

	if skill_id == "meteor":
		meteor_impact.emit()

	var fx: Dictionary = {
		"id": skill_id,
		"element": elem,
		"time": 0.0,
		"duration": 0.5,
		"target_pos": target_pos,
		"radius": rad,
		"impact_done": false,
		"eff": eff
	}
	active_effects.append(fx)
	queue_redraw()

func _update_active_effects(delta: float) -> void:
	var i: int = active_effects.size() - 1
	while i >= 0:
		var fx: Dictionary = active_effects[i]
		var t: float = float(fx["time"]) + delta
		fx["time"] = t

		if not bool(fx["impact_done"]) and t >= 0.15:
			fx["impact_done"] = true
			_apply_effect_damage(fx)

		if t >= float(fx["duration"]):
			active_effects.remove_at(i)
		i -= 1

	if not active_effects.is_empty():
		queue_redraw()

func _apply_effect_damage(fx: Dictionary) -> void:
	if enemies_container == null: return
	var target_pos: Vector2 = fx["target_pos"] as Vector2
	var rad: float = float(fx["radius"])
	var elem: String = fx["element"] as String
	var eff: Dictionary = fx["eff"] as Dictionary

	var pow_val: float = float(eff.get("power", 100.0))
	var maid_power: float = defender.damage if (defender != null and is_instance_valid(defender)) else 50.0
	var base_dmg: float = maid_power * (pow_val / 100.0)

	for child in enemies_container.get_children():
		if child is EnemyPlaceholder and is_instance_valid(child) and not child.is_dead:
			if child.position.distance_to(target_pos) <= rad + child.radius:
				var target_elem: String = child.stats.element if child.stats != null else "neutral"
				var mult: float = get_elemental_multiplier(elem, target_elem)
				var final_dmg: float = base_dmg * mult
				var is_crit: bool = mult > 1.2 or randf() < 0.2
				if defender != null and is_instance_valid(defender):
					child.take_damage_from_maid(final_dmg, is_crit, defender)
				else:
					child.take_damage(final_dmg, is_crit)

func reset_skills() -> void:
	for i in range(MAX_SLOTS):
		slot_cooldowns[i] = 0.0
	active_effects.clear()
	skill_state_changed.emit()

func to_dict() -> Dictionary:
	return {
		"unlocked_skills": unlocked_skills,
		"equipped_slots": equipped_slots,
		"slot_autos": slot_autos,
		"global_auto_skills": global_auto_skills
	}

func from_dict(data: Dictionary) -> void:
	if data.has("unlocked_skills") and data["unlocked_skills"] is Dictionary:
		unlocked_skills = data["unlocked_skills"].duplicate(true)
	if data.has("equipped_slots") and data["equipped_slots"] is Array:
		var sq: Array = data["equipped_slots"]
		for i in range(min(sq.size(), MAX_SLOTS)):
			equipped_slots[i] = str(sq[i])
	if data.has("slot_autos") and data["slot_autos"] is Array:
		var sa: Array = data["slot_autos"]
		for i in range(min(sa.size(), MAX_SLOTS)):
			slot_autos[i] = bool(sa[i])
	if data.has("global_auto_skills"):
		global_auto_skills = bool(data["global_auto_skills"])
	skill_state_changed.emit()

func _draw() -> void:
	for fx: Dictionary in active_effects:
		var t: float = float(fx["time"])
		var dur: float = float(fx["duration"])
		var target: Vector2 = fx["target_pos"] as Vector2
		var rad: float = float(fx["radius"])
		var elem: String = fx["element"] as String
		var ratio: float = clampf(t / dur, 0.0, 1.0)
		var alpha: float = clampf(1.0 - ratio, 0.0, 1.0)

		var col: Color = Color(1.0, 0.4, 0.1, alpha)
		match elem:
			"water": col = Color(0.2, 0.7, 1.0, alpha)
			"earth": col = Color(0.8, 0.6, 0.2, alpha)
			"wind": col = Color(0.3, 0.9, 0.6, alpha)

		draw_arc(target, rad * ratio, 0, TAU, 24, col, 3.0, true)
		draw_circle(target, rad * 0.4 * (1.0 - ratio), Color(col.r, col.g, col.b, alpha * 0.5))
