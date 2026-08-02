class_name EquipmentItem
extends RefCounted

enum Slot { WEAPON, ARMOR, RING, BOOTS }
enum Rarity { COMMON, RARE, EPIC, LEGENDARY, MYTHIC }

var id: String = ""
var name: String = ""
var slot: Slot = Slot.WEAPON
var rarity: Rarity = Rarity.COMMON

var attack_bonus: float = 0.0
var speed_bonus: float = 0.0
var crit_bonus: float = 0.0
var hp_bonus: float = 0.0

static func get_rarity_name(r: Rarity) -> String:
	match r:
		Rarity.COMMON: return "Common"
		Rarity.RARE: return "Rare"
		Rarity.EPIC: return "Epic"
		Rarity.LEGENDARY: return "Legendary"
		Rarity.MYTHIC: return "Mythic"
	return "Common"

static func get_rarity_color(r: Rarity) -> Color:
	match r:
		Rarity.COMMON: return Color(0.75, 0.78, 0.82, 1.0)
		Rarity.RARE: return Color(0.25, 0.65, 1.0, 1.0)
		Rarity.EPIC: return Color(0.7, 0.3, 0.95, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.6, 0.1, 1.0)
		Rarity.MYTHIC: return Color(1.0, 0.2, 0.35, 1.0)
	return Color(0.8, 0.8, 0.8, 1.0)

static func get_slot_name(s: Slot) -> String:
	match s:
		Slot.WEAPON: return "Weapon"
		Slot.ARMOR: return "Armor"
		Slot.RING: return "Ring"
		Slot.BOOTS: return "Boots"
	return "Weapon"

static func generate_random(target_slot: Slot = -1 as Slot, min_rarity: Rarity = Rarity.COMMON, stage_num: int = 1) -> EquipmentItem:
	var item: EquipmentItem = EquipmentItem.new()
	item.id = str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

	if target_slot < 0 or target_slot > Slot.BOOTS:
		item.slot = (randi() % 4) as Slot
	else:
		item.slot = target_slot

	item.rarity = _roll_rarity(min_rarity)

	var rarity_mult: float = 1.0
	match item.rarity:
		Rarity.COMMON: rarity_mult = 1.0
		Rarity.RARE: rarity_mult = 1.8
		Rarity.EPIC: rarity_mult = 3.2
		Rarity.LEGENDARY: rarity_mult = 5.5
		Rarity.MYTHIC: rarity_mult = 10.0

	var stage_mult: float = 1.0 + float(stage_num - 1) * 0.25

	# Generate name and stats based on slot
	match item.slot:
		Slot.WEAPON:
			var prefixes: Array[String] = ["Iron", "Steel", "Runed", "Vanquisher's", "Celestial"]
			item.name = prefixes[item.rarity] + " Bow"
			item.attack_bonus = roundf((8.0 + randf() * 4.0) * rarity_mult * stage_mult)
			item.crit_bonus = (0.01 + randf() * 0.02) * rarity_mult
		Slot.ARMOR:
			var prefixes: Array[String] = ["Padded", "Chainmail", "Guardian", "Aegis", "Dragonscale"]
			item.name = prefixes[item.rarity] + " Vest"
			item.hp_bonus = roundf((25.0 + randf() * 15.0) * rarity_mult * stage_mult)
		Slot.RING:
			var prefixes: Array[String] = ["Copper", "Silver", "Gold", "Ruby", "Diamond"]
			item.name = prefixes[item.rarity] + " Band"
			item.crit_bonus = (0.02 + randf() * 0.03) * rarity_mult
			item.attack_bonus = roundf((3.0 + randf() * 3.0) * rarity_mult * stage_mult)
		Slot.BOOTS:
			var prefixes: Array[String] = ["Leather", "Swift", "Windwalker", "Hermes'", "Phantom"]
			item.name = prefixes[item.rarity] + " Striders"
			item.speed_bonus = (0.03 + randf() * 0.03) * rarity_mult
			item.hp_bonus = roundf((10.0 + randf() * 10.0) * rarity_mult * stage_mult)

	return item

static func _roll_rarity(min_rarity: Rarity) -> Rarity:
	var roll: float = randf()
	var rolled: Rarity = Rarity.COMMON
	if roll < 0.03:
		rolled = Rarity.MYTHIC
	elif roll < 0.12:
		rolled = Rarity.LEGENDARY
	elif roll < 0.30:
		rolled = Rarity.EPIC
	elif roll < 0.60:
		rolled = Rarity.RARE
	else:
		rolled = Rarity.COMMON

	if int(rolled) < int(min_rarity):
		rolled = min_rarity
	return rolled
