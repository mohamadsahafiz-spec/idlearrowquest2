class_name WorldRegistry
extends RefCounted

const WORLDS: Array[Dictionary] = [
	{"id": 1, "name": "Royal Kingdom", "max_stages": 50},
	{"id": 2, "name": "Enchanted Forest", "max_stages": 100},
	{"id": 3, "name": "Frozen Kingdom", "max_stages": 200},
	{"id": 4, "name": "Gothic Realm", "max_stages": 350},
	{"id": 5, "name": "Infernal Realm", "max_stages": 500},
	{"id": 6, "name": "Celestial Realm", "max_stages": 750}
]

static func get_world_info(world_id: int) -> Dictionary:
	for w: Dictionary in WORLDS:
		if int(w.get("id", 0)) == world_id:
			return w
	return WORLDS[0]

static func get_max_stages(world_id: int) -> int:
	return int(get_world_info(world_id).get("max_stages", 50))

static func get_world_name(world_id: int) -> String:
	return str(get_world_info(world_id).get("name", "Royal Kingdom"))

static func get_next_world_id(world_id: int) -> int:
	if world_id >= WORLDS.size():
		return WORLDS.size()
	return world_id + 1

static func is_last_world(world_id: int) -> bool:
	return world_id >= WORLDS.size()

static func get_cumulative_stages_before(world_id: int) -> int:
	var total: int = 0
	for w: Dictionary in WORLDS:
		var w_id: int = int(w.get("id", 0))
		if w_id < world_id:
			total += int(w.get("max_stages", 0))
		else:
			break
	return total
