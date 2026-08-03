class_name SaveSystem
extends Node

signal save_completed()
signal offline_rewards_calculated(rewards: Dictionary)

var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null
var skill_system: SkillSystem = null
var maid_system: MaidSystem = null

var auto_upgrade_enabled: bool = false
var auto_equip_enabled: bool = false

var auto_upgrade_timer: float = 0.0
var auto_save_timer: float = 0.0
const SAVE_PATH: String = "user://save_data.json"
const AUTO_SAVE_INTERVAL: float = 8.0

func _ready() -> void:
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()

func _process(delta: float) -> void:
	# Periodic auto save
	auto_save_timer += delta
	if auto_save_timer >= AUTO_SAVE_INTERVAL:
		auto_save_timer = 0.0
		save_game()

	# Auto upgrade logic
	if auto_upgrade_enabled and progression_system != null:
		auto_upgrade_timer += delta
		if auto_upgrade_timer >= 0.4:
			auto_upgrade_timer = 0.0
			_process_auto_upgrade()

func _process_auto_upgrade() -> void:
	if progression_system == null:
		return
	var bought_any: bool = true
	var safety_counter: int = 0
	while bought_any and safety_counter < 10:
		safety_counter += 1
		bought_any = false
		var choices: Array[Dictionary] = []
		if progression_system.can_buy_attack():
			choices.append({"type": "attack", "level": progression_system.attack_level, "cost": progression_system.get_attack_cost()})
		if progression_system.can_buy_speed():
			choices.append({"type": "speed", "level": progression_system.speed_level, "cost": progression_system.get_speed_cost()})
		if progression_system.can_buy_crit():
			choices.append({"type": "crit", "level": progression_system.crit_level, "cost": progression_system.get_crit_cost()})
		if progression_system.can_buy_hp():
			choices.append({"type": "hp", "level": progression_system.hp_level, "cost": progression_system.get_hp_cost()})

		if choices.is_empty():
			break

		# Pick lowest level for balanced priority
		choices.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			if a["level"] != b["level"]:
				return a["level"] < b["level"]
			return a["cost"] < b["cost"]
		)

		var best: Dictionary = choices[0]
		match str(best["type"]):
			"attack": bought_any = progression_system.buy_attack()
			"speed": bought_any = progression_system.buy_speed()
			"crit": bought_any = progression_system.buy_crit()
			"hp": bought_any = progression_system.buy_hp()

func on_loot_dropped(_item: EquipmentItem) -> void:
	if auto_equip_enabled and equipment_system != null:
		equipment_system.auto_equip_best()

func save_game() -> void:
	if stage_system == null or progression_system == null or equipment_system == null or skill_system == null:
		return

	var inv_arr: Array = []
	for item: EquipmentItem in equipment_system.inventory:
		if item != null:
			inv_arr.append(item.to_dict())

	var eq_dict: Dictionary = {}
	for slot: int in equipment_system.equipped:
		var item: EquipmentItem = equipment_system.equipped[slot] as EquipmentItem
		eq_dict[str(slot)] = item.to_dict() if item != null else {}

	var auto_skills: Dictionary = {
		"meteor": skill_system.meteor_auto,
		"freeze": skill_system.freeze_auto,
		"overdrive": skill_system.overdrive_auto
	}

	var save_data: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"world": stage_system.current_world,
		"stage": stage_system.current_stage,
		"highest_unlocked_world": stage_system.highest_unlocked_world,
		"completed_worlds": stage_system.completed_worlds,
		"is_endless_mode": stage_system.is_endless_mode,
		"world_1_completed": stage_system.is_world_1_completed,
		"gold": progression_system.gold,
		"attack_level": progression_system.attack_level,
		"speed_level": progression_system.speed_level,
		"crit_level": progression_system.crit_level,
		"hp_level": progression_system.hp_level,
		"auto_upgrade": auto_upgrade_enabled,
		"auto_equip": auto_equip_enabled,
		"auto_skills": auto_skills,
		"inventory": inv_arr,
		"equipped": eq_dict,
		"maid_equipped": equipment_system.maid_equipped_to_dict() if equipment_system.has_method("maid_equipped_to_dict") else {},
		"maid_system": maid_system.to_dict() if maid_system != null else {}
	}

	var json_str: String = JSON.stringify(save_data)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(json_str)
		file.close()
		save_completed.emit()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var json_str: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(json_str)
	if parse_err != OK or not (json.data is Dictionary):
		return {}

	return json.data as Dictionary

func apply_save_data(data: Dictionary) -> float:
	if data.is_empty():
		return 0.0

	var saved_time: float = float(data.get("timestamp", 0.0))

	if stage_system != null:
		var loaded_world: int = int(data.get("world", 1))
		var loaded_stage: int = int(data.get("stage", 1))
		stage_system.highest_unlocked_world = int(data.get("highest_unlocked_world", loaded_world))
		stage_system.is_endless_mode = bool(data.get("is_endless_mode", false))
		
		var comp_w_arr: Array = data.get("completed_worlds", [])
		stage_system.completed_worlds.clear()
		for w in comp_w_arr:
			stage_system.completed_worlds.append(int(w))
		if bool(data.get("world_1_completed", false)) and not stage_system.completed_worlds.has(1):
			stage_system.completed_worlds.append(1)
		
		stage_system.start_stage(loaded_stage, loaded_world)

	if progression_system != null:
		progression_system.gold = int(data.get("gold", 0))
		progression_system.attack_level = int(data.get("attack_level", 1))
		progression_system.speed_level = int(data.get("speed_level", 1))
		progression_system.crit_level = int(data.get("crit_level", 1))
		progression_system.hp_level = int(data.get("hp_level", 1))
		progression_system.gold_changed.emit(progression_system.gold)
		progression_system.upgrade_applied.emit("load", 1)

	auto_upgrade_enabled = bool(data.get("auto_upgrade", false))
	auto_equip_enabled = bool(data.get("auto_equip", false))

	if skill_system != null:
		var auto_skills: Dictionary = data.get("auto_skills", {})
		skill_system.meteor_auto = bool(auto_skills.get("meteor", false))
		skill_system.freeze_auto = bool(auto_skills.get("freeze", false))
		skill_system.overdrive_auto = bool(auto_skills.get("overdrive", false))
		skill_system.skill_state_changed.emit()

	if maid_system != null:
		var maid_data: Dictionary = data.get("maid_system", {})
		maid_system.from_dict(maid_data)

	if equipment_system != null:
		equipment_system.inventory.clear()
		var inv_data: Array = data.get("inventory", [])
		for item_d: Dictionary in inv_data:
			if item_d is Dictionary:
				var item: EquipmentItem = EquipmentItem.from_dict(item_d)
				if item != null:
					equipment_system.inventory.append(item)

		var eq_data: Dictionary = data.get("equipped", {})
		for slot_str: String in eq_data:
			var slot_int: int = int(slot_str)
			var item_d: Dictionary = eq_data.get(slot_str, {})
			if item_d is Dictionary and not item_d.is_empty():
				equipment_system.equipped[slot_int] = EquipmentItem.from_dict(item_d)
			else:
				equipment_system.equipped[slot_int] = null

		if data.has("maid_equipped") and equipment_system.has_method("maid_equipped_from_dict"):
			equipment_system.maid_equipped_from_dict(data.get("maid_equipped", {}))

		equipment_system.inventory_changed.emit()
		if auto_equip_enabled:
			equipment_system.auto_equip_best()

	return saved_time

func delete_save_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func calculate_offline_rewards(saved_time: float) -> Dictionary:
	if saved_time <= 0.0:
		return {"has_rewards": false}

	var now: float = Time.get_unix_time_from_system()
	var elapsed: float = clampf(now - saved_time, 0.0, 28800.0) # max 8 hours (28800s)

	if elapsed < 10.0:
		return {"has_rewards": false}

	var stg: int = stage_system.current_stage if stage_system != null else 1
	var atk_l: int = progression_system.attack_level if progression_system != null else 1
	var spd_l: int = progression_system.speed_level if progression_system != null else 1

	var gold_per_sec: float = 2.0 + float(stg) * 1.5 + float(atk_l + spd_l) * 0.4
	var total_gold: int = int(round(gold_per_sec * elapsed))
	var items_count: int = int(floor(elapsed / 900.0)) # 1 item per 15 min

	return {
		"has_rewards": true,
		"elapsed": elapsed,
		"gold": total_gold,
		"items_count": items_count
	}

func claim_offline_rewards(rewards: Dictionary) -> void:
	if not bool(rewards.get("has_rewards", false)):
		return

	var reward_gold: int = int(rewards.get("gold", 0))
	var reward_items: int = int(rewards.get("items_count", 0))

	if progression_system != null and reward_gold > 0:
		progression_system.add_gold(reward_gold)

	if equipment_system != null and reward_items > 0:
		var stg: int = stage_system.current_stage if stage_system != null else 1
		for i: int in range(reward_items):
			var item: EquipmentItem = EquipmentItem.generate_random(-1 as EquipmentItem.Slot, EquipmentItem.Rarity.COMMON, stg)
			equipment_system.add_to_inventory(item)

	save_game()
