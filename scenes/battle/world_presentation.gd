class_name WorldPresentation
extends Node

enum WorldID {
	ROYAL_KINGDOM = 1
}

enum StageVariant {
	ROYAL_OUTSKIRTS = 0,
	KINGDOM_ROAD = 1,
	DAMAGED_VILLAGE = 2,
	ROYAL_CASTLE_FRONT = 3
}

var current_world: WorldID = WorldID.ROYAL_KINGDOM
var current_variant: StageVariant = StageVariant.ROYAL_OUTSKIRTS

func get_variant_for_stage(stage_num: int) -> StageVariant:
	var index: int = (stage_num - 1) % 4
	return index as StageVariant

func update_stage(stage_num: int) -> void:
	current_variant = get_variant_for_stage(stage_num)

func get_variant_name() -> String:
	match current_variant:
		StageVariant.ROYAL_OUTSKIRTS: return "Royal Outskirts"
		StageVariant.KINGDOM_ROAD: return "Kingdom Road"
		StageVariant.DAMAGED_VILLAGE: return "Damaged Village"
		StageVariant.ROYAL_CASTLE_FRONT: return "Royal Castle Front"
	return "Royal Outskirts"

func get_accent_color() -> Color:
	match current_variant:
		StageVariant.ROYAL_OUTSKIRTS: return Color(0.3, 0.8, 0.4)
		StageVariant.KINGDOM_ROAD: return Color(0.9, 0.75, 0.3)
		StageVariant.DAMAGED_VILLAGE: return Color(0.85, 0.4, 0.25)
		StageVariant.ROYAL_CASTLE_FRONT: return Color(0.65, 0.35, 0.9)
	return Color(0.3, 0.8, 0.4)

func get_enemy_visual_set() -> Dictionary:
	return {
		"world_id": current_world,
		"stage_variant": current_variant,
		"theme": get_variant_name()
	}

func get_boss_visual_set() -> Dictionary:
	return {
		"entrance_type": "royal_banner",
		"boss_name": "Royal Guardian",
		"has_death_vfx": true
	}
