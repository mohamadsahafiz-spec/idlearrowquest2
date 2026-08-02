class_name MaidRegistry
extends RefCounted

const MAIDS: Array[Dictionary] = [
	{
		"id": "001",
		"name": "Liria",
		"title": "Rookie Battle Maid Archer",
		"class_type": "Archer",
		"world_id": 1,
		"unlocked_by_default": true,
		"visual_resource": "res://scenes/battle/defender/liria_visual.gd",
		"base_combat_profile": {
			"attack": 25.0,
			"attack_speed": 1.25,
			"critical_chance": 0.05
		},
		"unlock_condition": "Default Starter Maid"
	},
	{
		"id": "002",
		"name": "Maid #002",
		"title": "Forest Battle Maid",
		"class_type": "Support",
		"world_id": 2,
		"unlocked_by_default": false,
		"visual_resource": "",
		"base_combat_profile": {
			"attack": 20.0,
			"attack_speed": 1.10,
			"critical_chance": 0.05
		},
		"unlock_condition": "Clear Enchanted Forest"
	},
	{
		"id": "003",
		"name": "Maid #003",
		"title": "Frost Battle Maid",
		"class_type": "Mage",
		"world_id": 3,
		"unlocked_by_default": false,
		"visual_resource": "",
		"base_combat_profile": {
			"attack": 30.0,
			"attack_speed": 1.00,
			"critical_chance": 0.08
		},
		"unlock_condition": "Clear Frozen Kingdom"
	},
	{
		"id": "004",
		"name": "Maid #004",
		"title": "Gothic Battle Maid",
		"class_type": "Assassin",
		"world_id": 4,
		"unlocked_by_default": false,
		"visual_resource": "",
		"base_combat_profile": {
			"attack": 35.0,
			"attack_speed": 1.35,
			"critical_chance": 0.15
		},
		"unlock_condition": "Clear Gothic Realm"
	},
	{
		"id": "005",
		"name": "Maid #005",
		"title": "Infernal Battle Maid",
		"class_type": "Berserker",
		"world_id": 5,
		"unlocked_by_default": false,
		"visual_resource": "",
		"base_combat_profile": {
			"attack": 45.0,
			"attack_speed": 0.90,
			"critical_chance": 0.10
		},
		"unlock_condition": "Clear Infernal Realm"
	},
	{
		"id": "006",
		"name": "Maid #006",
		"title": "Celestial Battle Maid",
		"class_type": "Paladin",
		"world_id": 6,
		"unlocked_by_default": false,
		"visual_resource": "",
		"base_combat_profile": {
			"attack": 50.0,
			"attack_speed": 1.15,
			"critical_chance": 0.12
		},
		"unlock_condition": "Clear Celestial Realm"
	}
]

static func get_maid_info(maid_id: String) -> Dictionary:
	for m: Dictionary in MAIDS:
		if str(m.get("id", "")) == maid_id:
			return m
	return {}

static func exists(maid_id: String) -> bool:
	return not get_maid_info(maid_id).is_empty()
