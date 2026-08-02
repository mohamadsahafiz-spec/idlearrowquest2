class_name MaidSystem
extends Node

signal maid_unlocked(maid_id: String)
signal party_changed(party_slots: Array)

var unlocked_maids: Dictionary = {}
var party_slots: Array[String] = ["001", "", "", "", "", ""]

func _ready() -> void:
	if unlocked_maids.is_empty():
		_init_default_roster()

func _init_default_roster() -> void:
	unlocked_maids.clear()
	for m: Dictionary in MaidRegistry.MAIDS:
		var maid_id: String = str(m.get("id", ""))
		if bool(m.get("unlocked_by_default", false)):
			unlocked_maids[maid_id] = {
				"id": maid_id,
				"level": 1,
				"exp": 0,
				"awakening_tier": 0,
				"equipped_items": {},
				"status": "active"
			}
	party_slots = ["001", "", "", "", "", ""]

func is_unlocked(maid_id: String) -> bool:
	return unlocked_maids.has(maid_id)

func unlock_maid(maid_id: String) -> bool:
	if not MaidRegistry.exists(maid_id):
		return false
	if is_unlocked(maid_id):
		return false
	unlocked_maids[maid_id] = {
		"id": maid_id,
		"level": 1,
		"exp": 0,
		"awakening_tier": 0,
		"equipped_items": {},
		"status": "active"
	}
	maid_unlocked.emit(maid_id)
	return true

func get_unlocked_maids() -> Array[String]:
	var result: Array[String] = []
	for k: String in unlocked_maids.keys():
		result.append(k)
	return result

func get_maid_data(maid_id: String) -> Dictionary:
	return unlocked_maids.get(maid_id, {})

func get_party() -> Array[String]:
	return party_slots.duplicate()

func set_party_slot(slot_index: int, maid_id: String) -> bool:
	if slot_index < 0 or slot_index >= 6:
		return false
	if not maid_id.is_empty():
		if not is_unlocked(maid_id):
			return false
		for i: int in range(6):
			if i != slot_index and party_slots[i] == maid_id:
				return false
	party_slots[slot_index] = maid_id
	validate_party()
	party_changed.emit(get_party())
	return true

func remove_from_party(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= 6:
		return false
	var count: int = 0
	for i: int in range(6):
		if not party_slots[i].is_empty():
			count += 1
	if count <= 1 and not party_slots[slot_index].is_empty():
		return false
	party_slots[slot_index] = ""
	validate_party()
	party_changed.emit(get_party())
	return true

func swap_party_slots(slot_a: int, slot_b: int) -> bool:
	if slot_a < 0 or slot_a >= 6 or slot_b < 0 or slot_b >= 6:
		return false
	var temp: String = party_slots[slot_a]
	party_slots[slot_a] = party_slots[slot_b]
	party_slots[slot_b] = temp
	validate_party()
	party_changed.emit(get_party())
	return true

func validate_party() -> void:
	if party_slots.size() != 6:
		while party_slots.size() < 6:
			party_slots.append("")
		if party_slots.size() > 6:
			party_slots = party_slots.slice(0, 6)
	
	var active_count: int = 0
	for i: int in range(6):
		var id: String = party_slots[i]
		if not id.is_empty() and is_unlocked(id):
			active_count += 1
		else:
			party_slots[i] = ""
			
	if active_count == 0 and is_unlocked("001"):
		party_slots[0] = "001"

func to_dict() -> Dictionary:
	return {
		"unlocked_maids": unlocked_maids.duplicate(true),
		"party_slots": party_slots.duplicate()
	}

func from_dict(data: Dictionary) -> void:
	if data.has("unlocked_maids") and data["unlocked_maids"] is Dictionary:
		unlocked_maids.clear()
		var loaded: Dictionary = data["unlocked_maids"]
		for k in loaded.keys():
			var maid_id: String = str(k)
			if MaidRegistry.exists(maid_id):
				var maid_info: Dictionary = loaded[k] if loaded[k] is Dictionary else {}
				unlocked_maids[maid_id] = {
					"id": maid_id,
					"level": int(maid_info.get("level", 1)),
					"exp": int(maid_info.get("exp", 0)),
					"awakening_tier": int(maid_info.get("awakening_tier", 0)),
					"equipped_items": maid_info.get("equipped_items", {}),
					"status": str(maid_info.get("status", "active"))
				}
	if not is_unlocked("001"):
		unlocked_maids["001"] = {
			"id": "001",
			"level": 1,
			"exp": 0,
			"awakening_tier": 0,
			"equipped_items": {},
			"status": "active"
		}

	if data.has("party_slots") and data["party_slots"] is Array:
		party_slots.clear()
		for item in data["party_slots"]:
			party_slots.append(str(item))
	validate_party()

func get_active_party_count() -> int:
	var count: int = 0
	for id: String in party_slots:
		if not id.is_empty() and is_unlocked(id):
			count += 1
	return count

func debug_unlock_all() -> void:
	for m: Dictionary in MaidRegistry.MAIDS:
		var m_id: String = str(m.get("id", ""))
		if not is_unlocked(m_id):
			unlock_maid(m_id)

func debug_set_party_count(count: int) -> void:
	debug_unlock_all()
	count = clampi(count, 1, 6)
	party_slots = ["", "", "", "", "", ""]
	for i in range(count):
		var m_id: String = "%03d" % (i + 1)
		party_slots[i] = m_id
	validate_party()
	party_changed.emit(get_party())
