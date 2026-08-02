class_name Battle
extends Control

@onready var arena_placeholder: ArenaPlaceholder = $ArenaPlaceholder
@onready var hud_placeholder: HUDPlaceholder = $HUDPlaceholder
var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null
var skill_system: SkillSystem = null
var maid_system: MaidSystem = null
var save_system: SaveSystem = null
var dev_panel: DevPanel = null

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

	maid_system = MaidSystem.new()
	maid_system.name = "MaidSystem"
	add_child(maid_system)

	skill_system = SkillSystem.new()
	skill_system.name = "SkillSystem"
	skill_system.z_index = 10
	if arena_placeholder != null:
		arena_placeholder.add_child(skill_system)
	else:
		add_child(skill_system)

	save_system = SaveSystem.new()
	save_system.name = "SaveSystem"
	save_system.stage_system = stage_system
	save_system.progression_system = progression_system
	save_system.equipment_system = equipment_system
	save_system.skill_system = skill_system
	save_system.maid_system = maid_system
	add_child(save_system)

	if equipment_system != null:
		equipment_system.loot_dropped.connect(save_system.on_loot_dropped)

	if arena_placeholder != null:
		arena_placeholder.stage_system = stage_system
		arena_placeholder.equipment_system = equipment_system
		arena_placeholder.skill_system = skill_system
		arena_placeholder.maid_system = maid_system
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
		hud_placeholder.save_system = save_system
		hud_placeholder.skill_requested.connect(_on_skill_requested)
		hud_placeholder.skill_auto_toggled.connect(_on_skill_auto_toggled)
		hud_placeholder.auto_upgrade_toggled.connect(_on_auto_upgrade_toggled)
		hud_placeholder.auto_equip_toggled.connect(_on_auto_equip_toggled)
		hud_placeholder.debug_sim_offline.connect(_on_debug_sim_offline)
		hud_placeholder.claim_offline_requested.connect(_on_claim_offline_requested)

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

	dev_panel = DevPanel.new()
	dev_panel.name = "DevPanel"
	dev_panel.battle = self
	dev_panel.stage_system = stage_system
	dev_panel.progression_system = progression_system
	dev_panel.equipment_system = equipment_system
	dev_panel.maid_system = maid_system
	dev_panel.save_system = save_system
	dev_panel.arena_placeholder = arena_placeholder
	dev_panel.visible = false
	add_child(dev_panel)

	if hud_placeholder != null:
		hud_placeholder.dev_toggled.connect(_on_dev_toggled)

	# Restore saved progress & check offline rewards
	var save_data: Dictionary = save_system.load_game()
	var saved_time: float = save_system.apply_save_data(save_data)
	if saved_time > 0.0:
		var offline_rewards: Dictionary = save_system.calculate_offline_rewards(saved_time)
		if bool(offline_rewards.get("has_rewards", false)) and hud_placeholder != null:
			hud_placeholder.offline_rewards_data = offline_rewards
			hud_placeholder.show_welcome_back = true

	if progression_system != null and arena_placeholder != null and arena_placeholder.defender != null:
		progression_system.apply_to_defender(arena_placeholder.defender, equipment_system, skill_system.is_overdrive_active())

	_update_hud_progression()

func _on_auto_upgrade_toggled() -> void:
	if save_system != null:
		save_system.auto_upgrade_enabled = not save_system.auto_upgrade_enabled
		if hud_placeholder != null:
			hud_placeholder.queue_redraw()

func _on_auto_equip_toggled() -> void:
	if save_system != null:
		save_system.auto_equip_enabled = not save_system.auto_equip_enabled
		if save_system.auto_equip_enabled and equipment_system != null:
			equipment_system.auto_equip_best()
		if hud_placeholder != null:
			hud_placeholder.queue_redraw()

func _on_debug_sim_offline(seconds: float) -> void:
	if save_system == null or hud_placeholder == null:
		return
	var sim_time: float = Time.get_unix_time_from_system() - seconds
	var rewards: Dictionary = save_system.calculate_offline_rewards(sim_time)
	if bool(rewards.get("has_rewards", false)):
		hud_placeholder.offline_rewards_data = rewards
		hud_placeholder.show_welcome_back = true
		hud_placeholder.queue_redraw()

func _on_claim_offline_requested() -> void:
	if save_system != null and hud_placeholder != null:
		save_system.claim_offline_rewards(hud_placeholder.offline_rewards_data)
		hud_placeholder.offline_rewards_data = {}
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var k_event: InputEventKey = event as InputEventKey
		if k_event.shift_pressed:
			match k_event.keycode:
				KEY_1: if maid_system != null: maid_system.debug_set_party_count(1)
				KEY_2: if maid_system != null: maid_system.debug_set_party_count(2)
				KEY_3: if maid_system != null: maid_system.debug_set_party_count(3)
				KEY_4: if maid_system != null: maid_system.debug_set_party_count(4)
				KEY_5: if maid_system != null: maid_system.debug_set_party_count(5)
				KEY_6: if maid_system != null: maid_system.debug_set_party_count(6)

func _on_equipment_changed() -> void:
	if progression_system != null and arena_placeholder != null:
		arena_placeholder.apply_progression_to_maids(progression_system, equipment_system, skill_system.is_overdrive_active() if skill_system != null else false)
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
	if progression_system != null and arena_placeholder != null:
		arena_placeholder.apply_progression_to_maids(progression_system, equipment_system, skill_system.is_overdrive_active() if skill_system != null else false)
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

func _on_dev_toggled() -> void:
	if dev_panel != null:
		dev_panel.visible = not dev_panel.visible
		if dev_panel.visible:
			move_child(dev_panel, get_child_count() - 1)

func reset_to_fresh_state() -> void:
	if stage_system != null:
		stage_system.start_stage(1, 1)
	if progression_system != null:
		progression_system.attack_level = 1
		progression_system.speed_level = 1
		progression_system.crit_level = 1
		progression_system.hp_level = 1
		progression_system.gold = 0
		progression_system.gold_changed.emit(0)
		progression_system.upgrade_applied.emit("all", 1)
	if equipment_system != null:
		equipment_system.inventory.clear()
		equipment_system.equipped.clear()
		equipment_system.inventory_changed.emit()
	if maid_system != null:
		maid_system.party_slots = ["001", "", "", "", "", ""]
		maid_system.party_changed.emit(maid_system.get_party())
	if arena_placeholder != null:
		arena_placeholder.reset_arena()

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

