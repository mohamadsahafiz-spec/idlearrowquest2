class_name Battle
extends Control

@onready var arena_placeholder: ArenaPlaceholder = $ArenaPlaceholder
@onready var hud_placeholder: HUDPlaceholder = $HUDPlaceholder
var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null
var skill_system: SkillSystem = null

func _ready() -> void:
	stage_system = StageSystem.new()
	stage_system.name = "StageSystem"
	add_child(stage_system)

	progression_system = ProgressionSystem.new()
	progression_system.name = "ProgressionSystem"
	add_child(progression_system)

	equipment_system = EquipmentSystem.new()
	equipment_system.name = "EquipmentSystem"
	add_child(equipment_system)

	skill_system = SkillSystem.new()
	skill_system.name = "SkillSystem"
	skill_system.z_index = 10
	if arena_placeholder != null:
		arena_placeholder.add_child(skill_system)
	else:
		add_child(skill_system)

	if arena_placeholder != null:
		arena_placeholder.stage_system = stage_system
		arena_placeholder.equipment_system = equipment_system
		arena_placeholder.skill_system = skill_system
		if arena_placeholder.defender != null:
			skill_system.defender = arena_placeholder.defender
		if arena_placeholder.enemies_container != null:
			skill_system.enemies_container = arena_placeholder.enemies_container
		if hud_placeholder != null:
			arena_placeholder.enemy_killed.connect(hud_placeholder.update_kill_count)
		if progression_system != null:
			arena_placeholder.gold_earned.connect(progression_system.add_gold)
		if arena_placeholder.defender != null and hud_placeholder != null:
			arena_placeholder.defender.hp_changed.connect(hud_placeholder.update_defender_hp)
			hud_placeholder.update_defender_hp(arena_placeholder.defender.current_hp, arena_placeholder.defender.max_hp)

	skill_system.stage_system = stage_system
	skill_system.progression_system = progression_system
	skill_system.equipment_system = equipment_system
	skill_system.skill_state_changed.connect(_on_skill_state_changed)

	if hud_placeholder != null:
		hud_placeholder.equipment_system = equipment_system
		hud_placeholder.skill_system = skill_system
		hud_placeholder.skill_requested.connect(_on_skill_requested)
		hud_placeholder.skill_auto_toggled.connect(_on_skill_auto_toggled)

	if equipment_system != null:
		equipment_system.inventory_changed.connect(_on_equipment_changed)
		if hud_placeholder != null:
			equipment_system.loot_dropped.connect(hud_placeholder.show_loot_notification)

	if progression_system != null:
		progression_system.gold_changed.connect(_on_progression_updated)
		progression_system.upgrade_applied.connect(_on_upgrade_applied)

	if hud_placeholder != null:
		hud_placeholder.upgrade_requested.connect(_on_upgrade_requested)
		hud_placeholder.restart_requested.connect(_on_restart_requested)

	if stage_system != null and hud_placeholder != null:
		stage_system.stage_updated.connect(hud_placeholder.update_stage_info)
		stage_system.banner_text_changed.connect(hud_placeholder.update_banner_text)
		stage_system.boss_state_changed.connect(hud_placeholder.update_boss_info)
		stage_system.victory_overlay_changed.connect(hud_placeholder.update_victory_overlay)
		stage_system.defeat_overlay_changed.connect(hud_placeholder.update_defeat_overlay)
		hud_placeholder.update_stage_info(
			stage_system.current_stage,
			stage_system.current_wave,
			stage_system.total_waves,
			stage_system.enemies_killed_this_wave,
			stage_system.enemies_required_this_wave
		)

	if progression_system != null and arena_placeholder != null and arena_placeholder.defender != null:
		progression_system.apply_to_defender(arena_placeholder.defender, equipment_system, skill_system.is_overdrive_active())

	_update_hud_progression()

func _on_skill_requested(skill_name: String) -> void:
	if skill_system != null:
		skill_system.trigger_skill(skill_name)

func _on_skill_auto_toggled(skill_name: String) -> void:
	if skill_system != null:
		skill_system.toggle_auto(skill_name)

func _on_skill_state_changed() -> void:
	if hud_placeholder != null:
		hud_placeholder.queue_redraw()

func _on_equipment_changed() -> void:
	if progression_system != null and arena_placeholder != null and arena_placeholder.defender != null:
		progression_system.apply_to_defender(arena_placeholder.defender, equipment_system, skill_system.is_overdrive_active() if skill_system != null else false)
	_update_hud_progression()

func _on_upgrade_requested(type: String) -> void:
	if progression_system == null:
		return
	match type:
		"attack":
			progression_system.buy_attack()
		"speed":
			progression_system.buy_speed()
		"crit":
			progression_system.buy_crit()
		"hp":
			progression_system.buy_hp()

func _on_upgrade_applied(_type: String, _level: int) -> void:
	if progression_system != null and arena_placeholder != null and arena_placeholder.defender != null:
		progression_system.apply_to_defender(arena_placeholder.defender, equipment_system, skill_system.is_overdrive_active() if skill_system != null else false)
	_update_hud_progression()

func _on_progression_updated(_current_gold: int) -> void:
	_update_hud_progression()

func _on_restart_requested() -> void:
	if skill_system != null:
		skill_system.reset_skills()
	if equipment_system != null:
		equipment_system.reset_equipment()
	if progression_system != null:
		progression_system.reset_progression()
	if arena_placeholder != null:
		arena_placeholder.reset_arena()
		if progression_system != null and arena_placeholder.defender != null:
			progression_system.apply_to_defender(arena_placeholder.defender, equipment_system)
	if stage_system != null:
		stage_system.start_stage(1)
	if arena_placeholder != null:
		arena_placeholder.spawn_enemy()
	_update_hud_progression()

func _update_hud_progression() -> void:
	if hud_placeholder != null and progression_system != null:
		hud_placeholder.update_progression_info(
			progression_system.gold,
			progression_system.attack_level,
			progression_system.get_attack_value(),
			progression_system.get_attack_value(progression_system.attack_level + 1),
			progression_system.get_attack_cost(),
			progression_system.speed_level,
			progression_system.get_speed_value(),
			progression_system.get_speed_value(progression_system.speed_level + 1),
			progression_system.get_speed_cost(),
			progression_system.is_speed_maxed(),
			progression_system.crit_level,
			progression_system.get_crit_value(),
			progression_system.get_crit_value(progression_system.crit_level + 1),
			progression_system.get_crit_cost(),
			progression_system.is_crit_maxed(),
			progression_system.hp_level,
			progression_system.get_hp_value(),
			progression_system.get_hp_value(progression_system.hp_level + 1),
			progression_system.get_hp_cost()
		)

