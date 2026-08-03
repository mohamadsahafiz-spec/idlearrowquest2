class_name EquipmentSystem
extends Node

signal inventory_changed()
signal item_equipped(item: EquipmentItem)
signal loot_dropped(item: EquipmentItem)

# Equipped slots: Slot (int) -> EquipmentItem
var equipped: Dictionary = {
	EquipmentItem.Slot.WEAPON: null,
	EquipmentItem.Slot.ARMOR: null,
	EquipmentItem.Slot.RING: null,
	EquipmentItem.Slot.BOOTS: null
}

func maid_equipped_to_dict() -> Dictionary:
	var res: Dictionary = {}
	var m001_dict: Dictionary = {}
	for slot: int in equipped:
		var item: EquipmentItem = equipped[slot] as EquipmentItem
		m001_dict[str(slot)] = item.to_dict() if item != null else {}
	res["001"] = m001_dict

	for m_id: String in maid_equipped:
		if m_id == "001":
			continue
		var eq: Dictionary = maid_equipped[m_id] as Dictionary
		var m_dict: Dictionary = {}
		for slot: int in eq:
			var item: EquipmentItem = eq[slot] as EquipmentItem
			m_dict[str(slot)] = item.to_dict() if item != null else {}
		res[m_id] = m_dict
	return res

func maid_equipped_from_dict(data: Dictionary) -> void:
	for m_id: String in data:
		var m_dict: Dictionary = data.get(m_id, {}) as Dictionary
		var eq_dict: Dictionary = {
			EquipmentItem.Slot.WEAPON: null,
			EquipmentItem.Slot.ARMOR: null,
			EquipmentItem.Slot.RING: null,
			EquipmentItem.Slot.BOOTS: null
		}
		for slot_str: String in m_dict:
			var slot_int: int = int(slot_str)
			var item_d: Dictionary = m_dict.get(slot_str, {})
			if item_d is Dictionary and not item_d.is_empty():
				eq_dict[slot_int] = EquipmentItem.from_dict(item_d)
		if m_id == "001":
			equipped = eq_dict
		else:
			maid_equipped[m_id] = eq_dict

# Per-maid equipped dictionary: maid_id (String) -> Dictionary of Slot (int) -> EquipmentItem
var maid_equipped: Dictionary = {}

func get_maid_equipped_dict(m_id: String) -> Dictionary:
	if m_id == "001":
		return equipped
	if not maid_equipped.has(m_id):
		maid_equipped[m_id] = {
			EquipmentItem.Slot.WEAPON: null,
			EquipmentItem.Slot.ARMOR: null,
			EquipmentItem.Slot.RING: null,
			EquipmentItem.Slot.BOOTS: null
		}
	return maid_equipped[m_id] as Dictionary

func equip_item_to_maid(m_id: String, item: EquipmentItem) -> bool:
	if item == null or not inventory.has(item):
		return false
	var slot: int = item.slot
	var eq_dict: Dictionary = get_maid_equipped_dict(m_id)
	var current_item: EquipmentItem = eq_dict.get(slot) as EquipmentItem

	inventory.erase(item)
	if current_item != null:
		inventory.append(current_item)

	eq_dict[slot] = item
	if m_id == "001":
		equipped[slot] = item
	item_equipped.emit(item)
	inventory_changed.emit()
	return true

func unequip_slot_from_maid(m_id: String, slot: EquipmentItem.Slot) -> bool:
	var eq_dict: Dictionary = get_maid_equipped_dict(m_id)
	var item: EquipmentItem = eq_dict.get(slot) as EquipmentItem
	if item != null:
		eq_dict[slot] = null
		if m_id == "001":
			equipped[slot] = null
		inventory.append(item)
		inventory_changed.emit()
		return true
	return false

func get_maid_attack_bonus(m_id: String) -> float:
	var total: float = 0.0
	var eq: Dictionary = get_maid_equipped_dict(m_id)
	for slot: int in eq:
		var item: EquipmentItem = eq[slot] as EquipmentItem
		if item != null:
			total += item.attack_bonus
	return total

func get_maid_speed_bonus(m_id: String) -> float:
	var total: float = 0.0
	var eq: Dictionary = get_maid_equipped_dict(m_id)
	for slot: int in eq:
		var item: EquipmentItem = eq[slot] as EquipmentItem
		if item != null:
			total += item.speed_bonus
	return total

func get_maid_crit_bonus(m_id: String) -> float:
	var total: float = 0.0
	var eq: Dictionary = get_maid_equipped_dict(m_id)
	for slot: int in eq:
		var item: EquipmentItem = eq[slot] as EquipmentItem
		if item != null:
			total += item.crit_bonus
	return total

func get_maid_hp_bonus(m_id: String) -> float:
	var total: float = 0.0
	var eq: Dictionary = get_maid_equipped_dict(m_id)
	for slot: int in eq:
		var item: EquipmentItem = eq[slot] as EquipmentItem
		if item != null:
			total += item.hp_bonus
	return total

# Inventory list
var inventory: Array[EquipmentItem] = []

# Debug settings
@export var debug_force_loot_drop: bool = false
@export var debug_force_rarity: EquipmentItem.Rarity = EquipmentItem.Rarity.COMMON

func add_to_inventory(item: EquipmentItem) -> void:
	if item != null:
		inventory.append(item)
		loot_dropped.emit(item)
		inventory_changed.emit()

func equip_item(item: EquipmentItem) -> bool:
	if item == null or not inventory.has(item):
		return false

	var slot: int = item.slot
	var current_equipped: EquipmentItem = equipped.get(slot) as EquipmentItem

	# Remove item from inventory
	inventory.erase(item)

	# Return currently equipped item to inventory if exists
	if current_equipped != null:
		inventory.append(current_equipped)

	# Equip new item
	equipped[slot] = item
	item_equipped.emit(item)
	inventory_changed.emit()
	return true

func unequip_slot(slot: EquipmentItem.Slot) -> bool:
	var item: EquipmentItem = equipped.get(slot) as EquipmentItem
	if item != null:
		equipped[slot] = null
		inventory.append(item)
		inventory_changed.emit()
		return true
	return false

func auto_equip_best() -> bool:
	var equipped_any: bool = false
	var slot_types: Array[int] = [
		EquipmentItem.Slot.WEAPON,
		EquipmentItem.Slot.ARMOR,
		EquipmentItem.Slot.RING,
		EquipmentItem.Slot.BOOTS
	]

	for s: int in slot_types:
		var slot: EquipmentItem.Slot = s as EquipmentItem.Slot
		var current: EquipmentItem = equipped.get(slot) as EquipmentItem
		var best_power: int = current.get_power() if current != null else -1
		var best_candidate: EquipmentItem = null

		for item: EquipmentItem in inventory:
			if item.slot == slot:
				var pwr: int = item.get_power()
				if pwr > best_power:
					best_power = pwr
					best_candidate = item

		if best_candidate != null:
			if equip_item(best_candidate):
				equipped_any = true

	return equipped_any

func get_total_attack_bonus() -> float:
	var total: float = 0.0
	for slot: int in equipped:
		var item: EquipmentItem = equipped[slot] as EquipmentItem
		if item != null:
			total += item.attack_bonus
	return total

func get_total_speed_bonus() -> float:
	var total: float = 0.0
	for slot: int in equipped:
		var item: EquipmentItem = equipped[slot] as EquipmentItem
		if item != null:
			total += item.speed_bonus
	return total

func get_total_crit_bonus() -> float:
	var total: float = 0.0
	for slot: int in equipped:
		var item: EquipmentItem = equipped[slot] as EquipmentItem
		if item != null:
			total += item.crit_bonus
	return total

func get_total_hp_bonus() -> float:
	var total: float = 0.0
	for slot: int in equipped:
		var item: EquipmentItem = equipped[slot] as EquipmentItem
		if item != null:
			total += item.hp_bonus
	return total

func roll_loot_drop(tier: EnemyStats.Tier, stage_num: int) -> EquipmentItem:
	if debug_force_loot_drop:
		var forced_item: EquipmentItem = EquipmentItem.generate_random(-1 as EquipmentItem.Slot, debug_force_rarity, stage_num)
		add_to_inventory(forced_item)
		return forced_item

	var drop_chance: float = 0.05
	var min_rarity: EquipmentItem.Rarity = EquipmentItem.Rarity.COMMON

	match tier:
		EnemyStats.Tier.NORMAL:
			drop_chance = 0.08
			min_rarity = EquipmentItem.Rarity.COMMON
		EnemyStats.Tier.STRONG:
			drop_chance = 0.20
			min_rarity = EquipmentItem.Rarity.COMMON
		EnemyStats.Tier.ELITE:
			drop_chance = 0.45
			min_rarity = EquipmentItem.Rarity.RARE
		EnemyStats.Tier.BOSS:
			drop_chance = 1.00 # Boss guaranteed drop
			min_rarity = EquipmentItem.Rarity.EPIC

	if randf() <= drop_chance:
		var item: EquipmentItem = EquipmentItem.generate_random(-1 as EquipmentItem.Slot, min_rarity, stage_num)
		add_to_inventory(item)
		return item

	return null

func reset_equipment() -> void:
	equipped[EquipmentItem.Slot.WEAPON] = null
	equipped[EquipmentItem.Slot.ARMOR] = null
	equipped[EquipmentItem.Slot.RING] = null
	equipped[EquipmentItem.Slot.BOOTS] = null
	inventory.clear()
	inventory_changed.emit()
