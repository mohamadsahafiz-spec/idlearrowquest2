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

	var drop_chance: float = 0.05 # Normal
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
