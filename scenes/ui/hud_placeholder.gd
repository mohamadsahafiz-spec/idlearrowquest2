class_name HUDPlaceholder
extends Control

signal upgrade_requested(type: String)
signal restart_requested()
signal continue_requested()
signal challenge_requested()
signal skill_requested(skill_name: String)
signal skill_auto_toggled(skill_name: String)
signal skill_slot_requested(slot_idx: int)
signal skill_slot_auto_toggled(slot_idx: int)
signal auto_upgrade_toggled()
signal auto_equip_toggled()
signal debug_sim_offline(seconds: float)
signal claim_offline_requested()
signal dev_toggled()

var skill_system: SkillSystem = null
var save_system: SaveSystem = null
var stage_system: StageSystem = null

var show_welcome_back: bool = false
var offline_rewards_data: Dictionary = {}

var kill_count: int = 0
var current_stage: int = 1
var current_wave: int = 1
var total_waves: int = 3
var wave_kills: int = 0
var wave_required_kills: int = 5
var banner_text: String = ""

var is_boss_active: bool = false
var boss_name: String = ""
var boss_hp: float = 0.0
var boss_max_hp: float = 1.0

var show_victory: bool = false
var victory_stage: int = 1
var show_defeat: bool = false

var gold: int = 0

var defender_hp: float = 100.0
var defender_max_hp: float = 100.0

var equipment_system: EquipmentSystem = null
var show_inventory: bool = false
var notification_text: String = ""
var notification_color: Color = Color.WHITE
var notification_timer: float = 0.0

func _process(delta: float) -> void:
	if notification_timer > 0.0:
		notification_timer -= delta
		if notification_timer <= 0.0:
			notification_timer = 0.0
		queue_redraw()

func show_loot_notification(item: EquipmentItem) -> void:
	if item == null:
		return
	var rarity_str: String = EquipmentItem.get_rarity_name(item.rarity)
	notification_text = "LOOT DROP: [" + rarity_str + "] " + item.name
	notification_color = EquipmentItem.get_rarity_color(item.rarity)
	notification_timer = 2.5
	queue_redraw()

var attack_level: int = 1
var attack_current: float = 15.0
var attack_next: float = 18.0
var attack_cost: int = 10

var speed_level: int = 1
var speed_current: float = 1.25
var speed_next: float = 1.35
var speed_cost: int = 15
var is_speed_maxed: bool = false

var crit_level: int = 1
var crit_current: float = 0.05
var crit_next: float = 0.07
var crit_cost: int = 20
var is_crit_maxed: bool = false

var hp_level: int = 1
var hp_current: float = 100.0
var hp_next: float = 125.0
var hp_cost: int = 12

func update_kill_count(count: int) -> void:
	kill_count = count
	queue_redraw()

func update_stage_info(stage: int, wave: int, max_waves: int, kills: int, required_kills: int) -> void:
	current_stage = stage
	current_wave = wave
	total_waves = max_waves
	wave_kills = kills
	wave_required_kills = required_kills
	queue_redraw()

func update_banner_text(text: String) -> void:
	banner_text = text
	queue_redraw()

func update_boss_info(active: bool, name_str: String, hp: float, max_hp: float) -> void:
	is_boss_active = active
	boss_name = name_str
	boss_hp = hp
	boss_max_hp = max_hp
	queue_redraw()

func update_victory_overlay(show: bool, stage_num: int) -> void:
	show_victory = show
	victory_stage = stage_num
	queue_redraw()

func update_defeat_overlay(show: bool) -> void:
	show_defeat = show
	queue_redraw()

func update_defender_hp(hp: float, max_hp: float) -> void:
	defender_hp = hp
	defender_max_hp = max_hp
	queue_redraw()

func update_progression_info(
	current_gold: int,
	atk_lvl: int, atk_curr: float, atk_nxt: float, atk_cst: int,
	spd_lvl: int, spd_curr: float, spd_nxt: float, spd_cst: int, spd_max: bool,
	crt_lvl: int, crt_curr: float, crt_nxt: float, crt_cst: int, crt_max: bool,
	hp_lvl: int, hp_curr: float, hp_nxt: float, hp_cst: int
) -> void:
	gold = current_gold
	attack_level = atk_lvl
	attack_current = atk_curr
	attack_next = atk_nxt
	attack_cost = atk_cst
	speed_level = spd_lvl
	speed_current = spd_curr
	speed_next = spd_nxt
	speed_cost = spd_cst
	is_speed_maxed = spd_max
	crit_level = crt_lvl
	crit_current = crt_curr
	crit_next = crt_nxt
	crit_cost = crt_cst
	is_crit_maxed = crt_max
	hp_level = hp_lvl
	hp_current = hp_curr
	hp_next = hp_nxt
	hp_cost = hp_cst
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = event.position

		# Top Bar DEV Button
		if Rect2(470, 22, 55, 22).has_point(pos):
			dev_toggled.emit()
			accept_event()
			queue_redraw()
			return

		# Top Bar Inventory / Equip Button
		if Rect2(254, 18, 110, 65).has_point(pos):
			show_inventory = not show_inventory
			accept_event()
			queue_redraw()
			return

		if show_inventory:
			# Close button
			if Rect2(470, 120, 40, 40).has_point(pos):
				show_inventory = false
				accept_event()
				queue_redraw()
				return

			# Equip Best button
			if Rect2(330, 120, 125, 36).has_point(pos):
				if equipment_system != null:
					equipment_system.auto_equip_best()
				accept_event()
				queue_redraw()
				return

			# Equipped slot click -> Unequip
			if equipment_system != null:
				if Rect2(25, 185, 230, 45).has_point(pos):
					equipment_system.unequip_slot(EquipmentItem.Slot.WEAPON)
					accept_event()
					queue_redraw()
					return
				elif Rect2(265, 185, 230, 45).has_point(pos):
					equipment_system.unequip_slot(EquipmentItem.Slot.ARMOR)
					accept_event()
					queue_redraw()
					return
				elif Rect2(25, 235, 230, 45).has_point(pos):
					equipment_system.unequip_slot(EquipmentItem.Slot.RING)
					accept_event()
					queue_redraw()
					return
				elif Rect2(265, 235, 230, 45).has_point(pos):
					equipment_system.unequip_slot(EquipmentItem.Slot.BOOTS)
					accept_event()
					queue_redraw()
					return

				# Inventory item row click -> Equip
				var inv_count: int = equipment_system.inventory.size()
				for i: int in range(mini(6, inv_count)):
					var row_rect: Rect2 = Rect2(25, 325 + i * 52, 490, 48)
					if row_rect.has_point(pos):
						equipment_system.equip_item(equipment_system.inventory[i])
						accept_event()
						queue_redraw()
						return

			# Block input behind inventory panel
			if Rect2(15, 110, 510, 570).has_point(pos):
				accept_event()
				return

		if show_defeat:
			if Rect2(150, 475, 240, 52).has_point(pos):
				continue_requested.emit()
				accept_event()
			return

		if stage_system != null and stage_system.is_progression_interrupted and stage_system.interrupt_reason != "defeat":
			if Rect2(150, 455, 240, 52).has_point(pos):
				stage_system.acknowledge_interrupt()
				accept_event()
				queue_redraw()
				return
			if Rect2(50, 280, 440, 260).has_point(pos):
				accept_event()
				return

		if stage_system != null and stage_system.is_farming_mode:
			if Rect2(371, 52, 90, 26).has_point(pos):
				challenge_requested.emit()
				accept_event()
				queue_redraw()
				return

		# Welcome Back Modal Claim click
		if show_welcome_back:
			if Rect2(150, 460, 240, 52).has_point(pos):
				claim_offline_requested.emit()
				show_welcome_back = false
				accept_event()
				queue_redraw()
				return
			if Rect2(50, 240, 440, 310).has_point(pos):
				accept_event()
				return

		# Idle Status Bar Clicks (y: 580 to 618)
		if Rect2(12, 580, 114, 38).has_point(pos):
			if skill_system != null:
				skill_system.global_auto_skills = not skill_system.global_auto_skills
				skill_system.skill_state_changed.emit()
				if save_system != null:
					save_system.save_game()
			accept_event()
			queue_redraw()
			return
		elif Rect2(132, 580, 120, 38).has_point(pos):
			auto_upgrade_toggled.emit()
			accept_event()
			queue_redraw()
			return
		elif Rect2(258, 580, 114, 38).has_point(pos):
			auto_equip_toggled.emit()
			accept_event()
			queue_redraw()
			return
		elif Rect2(378, 580, 70, 38).has_point(pos):
			debug_sim_offline.emit(3600.0)
			accept_event()
			queue_redraw()
			return
		elif Rect2(454, 580, 74, 38).has_point(pos):
			debug_sim_offline.emit(28800.0)
			accept_event()
			queue_redraw()
			return

		# Skill HUD Clicks (y: 626 to 686)
		if skill_system != null:
			var slot_count: int = skill_system.get_unlocked_slot_count()
			var total_w: float = 516.0
			var gap: float = 6.0
			var slot_w: float = (total_w - (slot_count - 1) * gap) / float(slot_count)
			for i in range(slot_count):
				var card_rect: Rect2 = Rect2(12 + i * (slot_w + gap), 626, slot_w, 60)
				if card_rect.has_point(pos):
					if pos.y >= 666:
						skill_slot_auto_toggled.emit(i)
					else:
						skill_slot_requested.emit(i)
					accept_event()
					queue_redraw()
					return

		if Rect2(10, 765, 124, 170).has_point(pos):
			upgrade_requested.emit("attack")
			accept_event()
		elif Rect2(142, 765, 124, 170).has_point(pos):
			upgrade_requested.emit("speed")
			accept_event()
		elif Rect2(274, 765, 124, 170).has_point(pos):
			upgrade_requested.emit("crit")
			accept_event()
		elif Rect2(406, 765, 124, 170).has_point(pos):
			upgrade_requested.emit("hp")
			accept_event()

func _draw() -> void:
	# Top HUD Header Area Placeholder (y: 0 to 105)
	var top_bar: Rect2 = Rect2(0, 0, 540, 105)
	draw_rect(top_bar, Color(0.05, 0.07, 0.1, 0.85))
	draw_line(Vector2(0, 105), Vector2(540, 105), Color(0.2, 0.35, 0.5, 0.8), 2.0)

	var font: Font = ThemeDB.fallback_font

	# Left: Total Kills Badge
	var kill_badge_rect: Rect2 = Rect2(10, 18, 115, 65)
	_draw_rounded_rect_filled(kill_badge_rect, 6.0, Color(0.08, 0.12, 0.18, 0.85))
	_draw_rounded_rect_stroke(kill_badge_rect, 6.0, Color(0.25, 0.4, 0.6, 0.7), 1.5)

	if font != null:
		draw_string(font, Vector2(18, 40), "KILLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.8, 0.9, 0.9))
		draw_string(font, Vector2(18, 62), str(kill_count), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.92, 0.96, 1.0, 0.95))

	# Center-Left: Gold Badge
	var gold_badge_rect: Rect2 = Rect2(132, 18, 115, 65)
	_draw_rounded_rect_filled(gold_badge_rect, 6.0, Color(0.08, 0.12, 0.08, 0.9))
	_draw_rounded_rect_stroke(gold_badge_rect, 6.0, Color(0.85, 0.7, 0.2, 0.8), 1.5)

	if font != null:
		draw_string(font, Vector2(140, 40), "GOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.7, 0.3, 0.9))
		draw_string(font, Vector2(140, 62), str(gold), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.88, 0.2, 1.0))

	# Center-Right: EQUIP / INVENTORY BUTTON
	var inv_count: int = equipment_system.inventory.size() if equipment_system != null else 0
	var equip_badge_rect: Rect2 = Rect2(254, 18, 110, 65)
	var btn_bg: Color = Color(0.18, 0.14, 0.28, 0.95) if inv_count > 0 else Color(0.1, 0.12, 0.18, 0.85)
	var btn_border: Color = Color(0.8, 0.5, 1.0, 0.9) if inv_count > 0 else Color(0.35, 0.4, 0.55, 0.8)
	_draw_rounded_rect_filled(equip_badge_rect, 6.0, btn_bg)
	_draw_rounded_rect_stroke(equip_badge_rect, 6.0, btn_border, 1.5)

	if font != null:
		draw_string(font, Vector2(309, 40), "EQUIP", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.9, 0.8, 1.0, 0.95))
		var bag_text: String = "BAG (" + str(inv_count) + ")"
		draw_string(font, Vector2(309, 62), bag_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(1.0, 0.9, 0.4, 1.0))

	# Right: Stage & Wave Info Badge
	var stage_badge_rect: Rect2 = Rect2(371, 18, 159, 65)
	_draw_rounded_rect_filled(stage_badge_rect, 6.0, Color(0.06, 0.1, 0.16, 0.92))
	_draw_rounded_rect_stroke(stage_badge_rect, 6.0, Color(0.3, 0.5, 0.75, 0.8), 1.5)

	if font != null:
		var stage_str: String = "Stage " + str(current_stage)
		if stage_system != null and stage_system.is_farming_mode:
			stage_str += " [FARM]"
			var ch_rect: Rect2 = Rect2(371, 52, 90, 26)
			_draw_rounded_rect_filled(ch_rect, 4.0, Color(0.85, 0.25, 0.25, 0.95))
			_draw_rounded_rect_stroke(ch_rect, 4.0, Color(1.0, 0.6, 0.6, 1.0), 1.0)
			draw_string(font, Vector2(416, 69), "CHALLENGE", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color.WHITE)
		var wave_str: String = "W: " + str(current_wave) + "/" + str(total_waves) + "  K: " + str(wave_kills) + "/" + str(wave_required_kills)
		draw_string(font, Vector2(379, 38), stage_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.9, 0.4, 1.0))
		draw_string(font, Vector2(379, 60), wave_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.92, 1.0, 0.95))

	# DEV Button
	var dev_btn_rect: Rect2 = Rect2(470, 22, 55, 22)
	_draw_rounded_rect_filled(dev_btn_rect, 4.0, Color(0.8, 0.2, 0.2, 0.95))
	_draw_rounded_rect_stroke(dev_btn_rect, 4.0, Color(1.0, 0.5, 0.5, 1.0), 1.0)
	if font != null:
		draw_string(font, Vector2(497, 37), "DEV", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)

	# Boss HUD Header Overlay
	if is_boss_active:
		_draw_boss_hud()

	# Active Skills HUD Bar (y: 626 to 686)
	_draw_skills_bar()

	# Idle Status Bar (y: 580 to 618)
	_draw_idle_status_bar()

	# Defender Stats & HP HUD Bar (y: 692 to 742)
	_draw_combat_stats_bar()

	# Victory / Defeat / Interrupt Overlay
	if show_defeat:
		_draw_defeat_overlay()
	elif stage_system != null and stage_system.is_progression_interrupted and stage_system.interrupt_reason != "defeat":
		_draw_interrupt_overlay()
	elif show_victory:
		_draw_victory_overlay()
	elif not banner_text.is_empty():
		_draw_banner_overlay()

	# Welcome Back Overlay
	if show_welcome_back:
		_draw_welcome_back()

	# Bottom Navigation / Upgrade Panel Area (y: 750 to 960)
	var bottom_bar: Rect2 = Rect2(0, 750, 540, 210)
	draw_rect(bottom_bar, Color(0.05, 0.07, 0.1, 0.9))
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)
	_draw_upgrade_panel()

	# Loot Notification Toast
	_draw_loot_notification()

	# Inventory & Equipment Panel Overlay
	if show_inventory:
		_draw_inventory_overlay()
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)
	_draw_upgrade_panel()

func _draw_combat_stats_bar() -> void:
	var font: Font = ThemeDB.fallback_font
	var bar_rect: Rect2 = Rect2(12, 694, 516, 48)
	_draw_rounded_rect_filled(bar_rect, 8.0, Color(0.06, 0.09, 0.14, 0.92))
	_draw_rounded_rect_stroke(bar_rect, 8.0, Color(0.25, 0.4, 0.55, 0.8), 1.5)

	# Defender HP Bar inside Panel
	var hp_bar_rect: Rect2 = Rect2(24, 718, 170, 14)
	draw_rect(hp_bar_rect, Color(0.08, 0.1, 0.14, 0.9))
	var pct: float = clampf(defender_hp / maxf(1.0, defender_max_hp), 0.0, 1.0)
	if pct > 0.0:
		var fill_col: Color = Color(0.2, 0.85, 0.4, 0.9)
		if pct <= 0.25:
			fill_col = Color(0.95, 0.25, 0.25, 0.9)
		elif pct <= 0.5:
			fill_col = Color(0.95, 0.75, 0.2, 0.9)
		draw_rect(Rect2(hp_bar_rect.position, Vector2(hp_bar_rect.size.x * pct, hp_bar_rect.size.y)), fill_col)
	draw_rect(hp_bar_rect, Color(0.4, 0.55, 0.7, 0.8), false, 1.0)

	if font != null:
		var pwr_val: int = ProgressionSystem.calculate_combat_power(attack_current, speed_current, crit_current, defender_max_hp)
		var hp_str: String = "HP: " + str(int(defender_hp)) + " / " + str(int(defender_max_hp))
		draw_string(font, Vector2(24, 710), hp_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.95, 1.0, 0.95))

		# Stats text on right side of panel
		var stats_str: String = "PWR: " + str(pwr_val) + "  ATK: " + str(int(attack_current)) + "  SPD: " + ("%.2f" % speed_current) + "/s  CRIT: " + str(int(crit_current * 100.0)) + "%"
		draw_string(font, Vector2(200, 723), stats_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.9, 0.4, 0.95))

func _draw_upgrade_panel() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	# Card 1: Attack
	_draw_upgrade_card(
		Rect2(10, 765, 124, 170),
		"ATTACK",
		"Lv. " + str(attack_level),
		str(int(attack_current)) + " -> " + str(int(attack_next)),
		attack_cost,
		gold >= attack_cost,
		false,
		font
	)

	# Card 2: Attack Speed
	_draw_upgrade_card(
		Rect2(142, 765, 124, 170),
		"ATK SPEED",
		"Lv. " + str(speed_level),
		("MAX" if is_speed_maxed else ("%.2f" % speed_current + "->" + "%.2f" % speed_next)),
		speed_cost,
		gold >= speed_cost and not is_speed_maxed,
		is_speed_maxed,
		font
	)

	# Card 3: Critical Chance
	_draw_upgrade_card(
		Rect2(274, 765, 124, 170),
		"CRITICAL",
		"Lv. " + str(crit_level),
		("MAX" if is_crit_maxed else (str(int(crit_current * 100.0)) + "%->" + str(int(crit_next * 100.0)) + "%")),
		crit_cost,
		gold >= crit_cost and not is_crit_maxed,
		is_crit_maxed,
		font
	)

	# Card 4: Max HP
	_draw_upgrade_card(
		Rect2(406, 765, 124, 170),
		"MAX HP",
		"Lv. " + str(hp_level),
		str(int(hp_current)) + " -> " + str(int(hp_next)),
		hp_cost,
		gold >= hp_cost,
		false,
		font
	)

func _draw_upgrade_card(rect: Rect2, title: String, level_str: String, stat_str: String, cost: int, can_afford: bool, is_maxed: bool, font: Font) -> void:
	var bg_col: Color = Color(0.08, 0.12, 0.18, 0.92) if can_afford else Color(0.05, 0.07, 0.09, 0.85)
	var stroke_col: Color = Color(0.95, 0.8, 0.25, 0.9) if can_afford else Color(0.25, 0.3, 0.35, 0.5)
	var title_col: Color = Color(1.0, 0.9, 0.3, 1.0) if can_afford else Color(0.55, 0.6, 0.65, 0.7)

	_draw_rounded_rect_filled(rect, 8.0, bg_col)
	_draw_rounded_rect_stroke(rect, 8.0, stroke_col, 1.5)

	var cx: float = rect.position.x + rect.size.x * 0.5

	# Title
	draw_string(font, Vector2(cx, rect.position.y + 24), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, title_col)
	# Level
	draw_string(font, Vector2(cx, rect.position.y + 44), level_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.85, 0.92, 1.0, 0.9))
	# Stat Preview
	draw_string(font, Vector2(cx, rect.position.y + 70), stat_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.75, 0.88, 0.98, 0.85))

	# Purchase Button Area inside Card
	var btn_rect: Rect2 = Rect2(rect.position.x + 8, rect.position.y + 105, 108, 48)
	var btn_bg: Color = Color(0.85, 0.65, 0.15, 0.95) if can_afford else Color(0.12, 0.14, 0.18, 0.8)
	var btn_stroke: Color = Color(1.0, 0.85, 0.3, 1.0) if can_afford else Color(0.25, 0.28, 0.32, 0.6)
	var btn_text_col: Color = Color(0.08, 0.06, 0.02, 1.0) if can_afford else Color(0.45, 0.5, 0.55, 0.7)

	_draw_rounded_rect_filled(btn_rect, 6.0, btn_bg)
	_draw_rounded_rect_stroke(btn_rect, 6.0, btn_stroke, 1.0)

	var cost_str: String = "MAX" if is_maxed else ("GOLD " + str(cost))
	draw_string(font, Vector2(cx, btn_rect.position.y + 22), cost_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, btn_text_col)
	var action_str: String = "MAXED" if is_maxed else ("UPGRADE" if can_afford else "LOCKED")
	draw_string(font, Vector2(cx, btn_rect.position.y + 38), action_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, btn_text_col)

func _draw_banner_overlay() -> void:
	var font: Font = ThemeDB.fallback_font
	var banner_rect: Rect2 = Rect2(50, 400, 440, 72)
	
	var is_boss: bool = (banner_text == "BOSS INCOMING")
	var bg_col: Color = Color(0.12, 0.03, 0.05, 0.94) if is_boss else Color(0.04, 0.09, 0.12, 0.92)
	var stroke_col: Color = Color(1.0, 0.3, 0.2, 0.95) if is_boss else Color(0.2, 0.85, 0.65, 0.95)
	var text_col: Color = Color(1.0, 0.88, 0.2, 1.0) if is_boss else Color(0.85, 1.0, 0.9, 1.0)

	_draw_rounded_rect_filled(banner_rect, 10.0, bg_col)
	_draw_rounded_rect_stroke(banner_rect, 10.0, stroke_col, 2.0)

	if font != null:
		var text_pos: Vector2 = Vector2(270, 444)
		# Shadow
		draw_string(font, text_pos + Vector2(2, 2), banner_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, Color(0.0, 0.0, 0.0, 0.9))
		# Main Banner Text
		draw_string(font, text_pos, banner_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, text_col)

func _draw_boss_hud() -> void:
	var font: Font = ThemeDB.fallback_font
	var bar_rect: Rect2 = Rect2(90, 112, 360, 42)

	_draw_rounded_rect_filled(bar_rect, 8.0, Color(0.12, 0.03, 0.05, 0.94))
	_draw_rounded_rect_stroke(bar_rect, 8.0, Color(0.85, 0.2, 0.25, 0.92), 1.5)

	if font != null:
		var name_pos: Vector2 = Vector2(270, 128)
		draw_string(font, name_pos + Vector2(1, 1), boss_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.0, 0.0, 0.0, 0.9))
		draw_string(font, name_pos, boss_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(1.0, 0.85, 0.25, 1.0))

	var hp_bar_rect: Rect2 = Rect2(102, 134, 336, 12)
	draw_rect(hp_bar_rect, Color(0.05, 0.05, 0.08, 0.85))

	var pct: float = clampf(boss_hp / maxf(1.0, boss_max_hp), 0.0, 1.0)
	if pct > 0.0:
		var fill_w: float = hp_bar_rect.size.x * pct
		var fill_rect: Rect2 = Rect2(hp_bar_rect.position, Vector2(fill_w, hp_bar_rect.size.y))
		var fill_col: Color = Color(0.92, 0.18, 0.22, 0.95)
		draw_rect(fill_rect, fill_col)

	draw_rect(hp_bar_rect, Color(0.6, 0.2, 0.25, 0.8), false, 1.0)

	if font != null:
		var hp_str: String = str(int(boss_hp)) + " / " + str(int(boss_max_hp))
		draw_string(font, Vector2(270, 144), hp_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1.0, 1.0, 1.0, 0.95))

func _draw_victory_overlay() -> void:
	var font: Font = ThemeDB.fallback_font
	var victory_rect: Rect2 = Rect2(50, 380, 440, 110)

	_draw_rounded_rect_filled(victory_rect, 12.0, Color(0.04, 0.12, 0.08, 0.95))
	_draw_rounded_rect_stroke(victory_rect, 12.0, Color(1.0, 0.85, 0.25, 1.0), 2.5)

	if font != null:
		var title_pos: Vector2 = Vector2(270, 424)
		var subtitle_pos: Vector2 = Vector2(270, 460)
		var sub_text: String = "Stage " + str(victory_stage) + " Complete"

		draw_string(font, title_pos + Vector2(2, 2), "VICTORY", HORIZONTAL_ALIGNMENT_CENTER, -1, 28, Color(0.0, 0.0, 0.0, 0.9))
		draw_string(font, title_pos, "VICTORY", HORIZONTAL_ALIGNMENT_CENTER, -1, 28, Color(1.0, 0.88, 0.2, 1.0))

		draw_string(font, subtitle_pos + Vector2(1, 1), sub_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 17, Color(0.0, 0.0, 0.0, 0.85))
		draw_string(font, subtitle_pos, sub_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 17, Color(0.85, 0.98, 0.9, 1.0))

func _draw_interrupt_overlay() -> void:
	if stage_system == null or not stage_system.is_progression_interrupted or stage_system.interrupt_reason == "defeat":
		return
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	# Dim background
	draw_rect(Rect2(0, 0, 540, 960), Color(0.0, 0.0, 0.0, 0.75))

	var modal_rect: Rect2 = Rect2(50, 280, 440, 260)
	_draw_rounded_rect_filled(modal_rect, 12.0, Color(0.06, 0.09, 0.16, 0.98))
	_draw_rounded_rect_stroke(modal_rect, 12.0, Color(0.3, 0.75, 1.0, 1.0), 2.5)

	var title_text: String = "PROGRESSION UNLOCK"
	if stage_system.interrupt_reason == "slot_unlocked":
		title_text = "SKILL SLOT UNLOCKED"
	elif stage_system.interrupt_reason == "maid_unlocked":
		title_text = "MAID UNLOCKED"

	draw_string(font, Vector2(270, 325), title_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, Color(1.0, 0.88, 0.2, 1.0))

	var detail_text: String = stage_system.interrupt_detail
	if detail_text.is_empty():
		detail_text = "New progression feature unlocked!"
	draw_string(font, Vector2(270, 370), detail_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(0.9, 0.95, 1.0, 0.95))

	var desc_text: String = "Action required: Review your new loadout."
	draw_string(font, Vector2(270, 405), desc_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.7, 0.8, 0.9, 0.8))

	# Confirm / Resume button
	var btn_rect: Rect2 = Rect2(150, 455, 240, 52)
	_draw_rounded_rect_filled(btn_rect, 8.0, Color(0.15, 0.55, 0.85, 0.95))
	_draw_rounded_rect_stroke(btn_rect, 8.0, Color(0.4, 0.8, 1.0, 1.0), 1.5)
	draw_string(font, Vector2(270, 488), "ACKNOWLEDGE & RESUME", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

func _draw_loot_notification() -> void:
	if notification_timer <= 0.0 or notification_text.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	var toast_rect: Rect2 = Rect2(30, 112, 480, 42)
	_draw_rounded_rect_filled(toast_rect, 8.0, Color(0.06, 0.08, 0.12, 0.96))
	_draw_rounded_rect_stroke(toast_rect, 8.0, notification_color, 2.0)

	if font != null:
		var pos: Vector2 = Vector2(270, 138)
		draw_string(font, pos + Vector2(1, 1), notification_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.0, 0.0, 0.0, 0.9))
		draw_string(font, pos, notification_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, notification_color)

func _draw_inventory_overlay() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	var panel_rect: Rect2 = Rect2(15, 110, 510, 570)
	_draw_rounded_rect_filled(panel_rect, 10.0, Color(0.06, 0.08, 0.12, 0.96))
	_draw_rounded_rect_stroke(panel_rect, 10.0, Color(0.85, 0.7, 0.2, 0.9), 2.0)

	# Panel Title
	draw_string(font, Vector2(200, 142), "EQUIPMENT & INVENTORY", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(1.0, 0.9, 0.3, 1.0))

	# Equip Best Button
	var best_rect: Rect2 = Rect2(330, 120, 125, 36)
	_draw_rounded_rect_filled(best_rect, 6.0, Color(0.15, 0.55, 0.85, 0.95))
	_draw_rounded_rect_stroke(best_rect, 6.0, Color(0.4, 0.85, 1.0, 1.0), 1.0)
	draw_string(font, Vector2(392, 143), "EQUIP BEST", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color.WHITE)

	# Close Button
	var close_rect: Rect2 = Rect2(470, 120, 40, 40)
	_draw_rounded_rect_filled(close_rect, 6.0, Color(0.8, 0.2, 0.25, 0.9))
	_draw_rounded_rect_stroke(close_rect, 6.0, Color(1.0, 0.4, 0.4, 1.0), 1.0)
	draw_string(font, Vector2(490, 145), "X", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

	# Equipped Slots Title
	draw_string(font, Vector2(30, 175), "EQUIPPED SLOTS (Click slot to Unequip):", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.9, 1.0, 0.9))

	var slot_rects: Array[Rect2] = [
		Rect2(25, 185, 230, 45),
		Rect2(265, 185, 230, 45),
		Rect2(25, 235, 230, 45),
		Rect2(265, 235, 230, 45)
	]
	var slot_types: Array[int] = [
		EquipmentItem.Slot.WEAPON,
		EquipmentItem.Slot.ARMOR,
		EquipmentItem.Slot.RING,
		EquipmentItem.Slot.BOOTS
	]

	for i: int in range(4):
		var s_rect: Rect2 = slot_rects[i]
		var s_type: int = slot_types[i]
		var s_name: String = EquipmentItem.get_slot_name(s_type as EquipmentItem.Slot)
		var equipped_item: EquipmentItem = equipment_system.equipped[s_type] as EquipmentItem if equipment_system != null else null

		if equipped_item != null:
			var r_col: Color = EquipmentItem.get_rarity_color(equipped_item.rarity)
			_draw_rounded_rect_filled(s_rect, 6.0, Color(0.1, 0.14, 0.2, 0.95))
			_draw_rounded_rect_stroke(s_rect, 6.0, r_col, 1.5)

			draw_string(font, Vector2(s_rect.position.x + 10, s_rect.position.y + 20), s_name + ": " + equipped_item.name, HORIZONTAL_ALIGNMENT_LEFT, 210, 11, r_col)

			var stat_str: String = _get_item_stat_string(equipped_item)
			draw_string(font, Vector2(s_rect.position.x + 10, s_rect.position.y + 36), stat_str, HORIZONTAL_ALIGNMENT_LEFT, 210, 10, Color(0.85, 0.92, 1.0, 0.85))
		else:
			_draw_rounded_rect_filled(s_rect, 6.0, Color(0.08, 0.09, 0.12, 0.7))
			_draw_rounded_rect_stroke(s_rect, 6.0, Color(0.25, 0.3, 0.35, 0.6), 1.0)
			draw_string(font, Vector2(s_rect.position.x + 10, s_rect.position.y + 27), "[" + s_name + "] Empty", HORIZONTAL_ALIGNMENT_LEFT, 210, 11, Color(0.5, 0.55, 0.6, 0.8))

	# Inventory List Title
	var inv_items: Array = equipment_system.inventory if equipment_system != null else []
	draw_string(font, Vector2(30, 310), "INVENTORY BAG (" + str(inv_items.size()) + " Items - Click row to Equip):", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.9, 1.0, 0.9))

	if inv_items.is_empty():
		draw_string(font, Vector2(270, 460), "Inventory is empty.\nDefeat enemies to get equipment drops!", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.6, 0.65, 0.7, 0.8))
	else:
		var max_display: int = mini(6, inv_items.size())
		for i: int in range(max_display):
			var item: EquipmentItem = inv_items[i] as EquipmentItem
			var row_rect: Rect2 = Rect2(25, 325 + i * 52, 490, 48)
			var r_col: Color = EquipmentItem.get_rarity_color(item.rarity)

			_draw_rounded_rect_filled(row_rect, 6.0, Color(0.09, 0.12, 0.18, 0.92))
			_draw_rounded_rect_stroke(row_rect, 6.0, r_col, 1.5)

			var cur_eq: EquipmentItem = equipment_system.equipped[item.slot] as EquipmentItem if equipment_system != null else null
			var comp_str: String = EquipmentItem.get_comparison_string(item, cur_eq)

			var title_text: String = "[" + EquipmentItem.get_rarity_name(item.rarity) + "] " + item.name + " (" + EquipmentItem.get_slot_name(item.slot) + ") Lv." + str(item.item_level)
			draw_string(font, Vector2(row_rect.position.x + 12, row_rect.position.y + 20), title_text, HORIZONTAL_ALIGNMENT_LEFT, 360, 12, r_col)

			var stat_str: String = _get_item_stat_string(item) + " | vs Eq: " + comp_str
			draw_string(font, Vector2(row_rect.position.x + 12, row_rect.position.y + 38), stat_str, HORIZONTAL_ALIGNMENT_LEFT, 360, 10, Color(0.85, 0.92, 1.0, 0.85))

			# Equip Button Badge
			var eq_btn_rect: Rect2 = Rect2(row_rect.position.x + 390, row_rect.position.y + 8, 88, 32)
			_draw_rounded_rect_filled(eq_btn_rect, 4.0, Color(0.15, 0.65, 0.3, 0.9))
			_draw_rounded_rect_stroke(eq_btn_rect, 4.0, Color(0.3, 0.9, 0.5, 1.0), 1.0)
			draw_string(font, Vector2(eq_btn_rect.position.x + 44, eq_btn_rect.position.y + 21), "EQUIP", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color.WHITE)

func _get_item_stat_string(item: EquipmentItem) -> String:
	var parts: Array[String] = []
	if item.attack_bonus > 0.0:
		parts.append("+" + str(int(item.attack_bonus)) + " ATK")
	if item.speed_bonus > 0.0:
		parts.append("+" + ("%.2f" % item.speed_bonus) + " SPD")
	if item.crit_bonus > 0.0:
		parts.append("+" + str(int(item.crit_bonus * 100.0)) + "% CRIT")
	if item.hp_bonus > 0.0:
		parts.append("+" + str(int(item.hp_bonus)) + " HP")
	return ", ".join(parts)

func _draw_defeat_overlay() -> void:
	var font: Font = ThemeDB.fallback_font
	var defeat_rect: Rect2 = Rect2(40, 360, 460, 190)

	_draw_rounded_rect_filled(defeat_rect, 12.0, Color(0.12, 0.03, 0.04, 0.96))
	_draw_rounded_rect_stroke(defeat_rect, 12.0, Color(0.9, 0.2, 0.25, 1.0), 2.5)

	if font != null:
		var title_pos: Vector2 = Vector2(270, 412)
		var subtitle_pos: Vector2 = Vector2(270, 448)

		draw_string(font, title_pos + Vector2(2, 2), "DEFEAT", HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color(0.0, 0.0, 0.0, 0.9))
		draw_string(font, title_pos, "DEFEAT", HORIZONTAL_ALIGNMENT_CENTER, -1, 32, Color(1.0, 0.25, 0.25, 1.0))

		draw_string(font, subtitle_pos + Vector2(1, 1), "Defender Destroyed", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.0, 0.0, 0.0, 0.85))
		draw_string(font, subtitle_pos, "Defender Destroyed", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.95, 0.75, 0.75, 1.0))

		# Continue Button
		var btn_rect: Rect2 = Rect2(150, 475, 240, 52)
		_draw_rounded_rect_filled(btn_rect, 8.0, Color(0.85, 0.65, 0.15, 0.95))
		_draw_rounded_rect_stroke(btn_rect, 8.0, Color(1.0, 0.88, 0.3, 1.0), 1.5)

		var btn_text_pos: Vector2 = Vector2(270, 508)
		draw_string(font, btn_text_pos + Vector2(1, 1), "CONTINUE (FARM)", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(0.0, 0.0, 0.0, 0.9))
		draw_string(font, btn_text_pos, "CONTINUE (FARM)", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(0.08, 0.06, 0.02, 1.0))

func _draw_skills_bar() -> void:
	if skill_system == null:
		return
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	var slot_count: int = skill_system.get_unlocked_slot_count()
	var total_w: float = 516.0
	var gap: float = 6.0
	var slot_w: float = (total_w - (slot_count - 1) * gap) / float(slot_count)

	for i in range(slot_count):
		var card_rect: Rect2 = Rect2(12 + i * (slot_w + gap), 626, slot_w, 60)
		var sk_id: String = skill_system.equipped_slots[i] if i < skill_system.equipped_slots.size() else ""
		var is_ready: bool = skill_system.is_slot_ready(i)
		var cd: float = skill_system.slot_cooldowns[i] if i < skill_system.slot_cooldowns.size() else 0.0
		var auto_on: bool = skill_system.slot_autos[i] if i < skill_system.slot_autos.size() else false

		var eff: Dictionary = skill_system.get_skill_effective_stats(sk_id)
		var sk_name: String = eff.get("name", "EMPTY") as String
		var sk_elem: String = eff.get("element", "fire") as String
		var sk_lvl: int = int(eff.get("level", 1))

		var theme_color: Color = Color(1.0, 0.4, 0.1, 1.0)
		match sk_elem:
			"water": theme_color = Color(0.2, 0.7, 1.0, 1.0)
			"earth": theme_color = Color(0.85, 0.65, 0.2, 1.0)
			"wind": theme_color = Color(0.3, 0.9, 0.6, 1.0)

		var bg_col: Color = Color(0.08, 0.09, 0.12, 0.9)
		var stroke_col: Color = Color(0.25, 0.3, 0.38, 0.6)
		var status_text: String = "READY"
		var status_col: Color = Color(0.6, 0.65, 0.7, 0.7)

		if sk_id.is_empty():
			status_text = "EMPTY"
		elif is_ready:
			bg_col = theme_color.darkened(0.7)
			stroke_col = theme_color.lightened(0.2)
			status_text = "READY"
			status_col = Color(1.0, 0.92, 0.4, 1.0)
		elif cd > 0.0:
			status_text = "%.1fs" % cd

		_draw_rounded_rect_filled(card_rect, 6.0, bg_col)
		_draw_rounded_rect_stroke(card_rect, 6.0, stroke_col, 1.5 if is_ready else 1.0)

		var cx: float = card_rect.position.x + card_rect.size.x * 0.5
		var font_sz: int = 10 if slot_count <= 4 else 8
		draw_string(font, Vector2(cx, card_rect.position.y + 18), sk_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, -1, font_sz, theme_color if is_ready else Color(0.7, 0.75, 0.8, 0.8))
		draw_string(font, Vector2(cx, card_rect.position.y + 32), "Lv." + str(sk_lvl) + " " + status_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, status_col)

		# Auto toggle bar at bottom of card
		var auto_bg: Color = Color(0.08, 0.22, 0.12, 0.95) if auto_on else Color(0.06, 0.08, 0.11, 0.85)
		var auto_stroke: Color = Color(0.25, 0.85, 0.45, 0.9) if auto_on else Color(0.25, 0.3, 0.35, 0.5)
		var auto_bar_rect: Rect2 = Rect2(card_rect.position.x + 2, card_rect.position.y + 40, card_rect.size.x - 4, 17)
		_draw_rounded_rect_filled(auto_bar_rect, 4.0, auto_bg)
		_draw_rounded_rect_stroke(auto_bar_rect, 4.0, auto_stroke, 1.0)
		draw_string(font, Vector2(cx, auto_bar_rect.position.y + 12), "AUTO " + ("[ON]" if auto_on else "[OFF]"), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.3, 1.0, 0.5, 1.0) if auto_on else Color(0.5, 0.55, 0.6, 0.6))

func _draw_idle_status_bar() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	var skills_on: bool = skill_system.global_auto_skills if skill_system != null else false
	var auto_upg_on: bool = save_system.auto_upgrade_enabled if save_system != null else false
	var auto_eq_on: bool = save_system.auto_equip_enabled if save_system != null else false

	# 1. Auto Skills Status (Rect2(12, 580, 114, 38))
	var box1_rect: Rect2 = Rect2(12, 580, 114, 38)
	var box1_bg: Color = Color(0.08, 0.22, 0.12, 0.95) if skills_on else Color(0.06, 0.08, 0.11, 0.85)
	var box1_stroke: Color = Color(0.25, 0.85, 0.45, 0.9) if skills_on else Color(0.25, 0.3, 0.35, 0.5)
	_draw_rounded_rect_filled(box1_rect, 6.0, box1_bg)
	_draw_rounded_rect_stroke(box1_rect, 6.0, box1_stroke, 1.2)
	draw_string(font, Vector2(69, 595), "AUTO SKILLS", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.85, 0.9, 0.95, 0.9) if skills_on else Color(0.55, 0.6, 0.65, 0.7))
	draw_string(font, Vector2(69, 610), "[ON]" if skills_on else "[OFF]", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.3, 1.0, 0.5, 1.0) if skills_on else Color(0.5, 0.55, 0.6, 0.7))

	# 2. Auto Upgrade Toggle Button (Rect2(132, 580, 120, 38))
	var box2_rect: Rect2 = Rect2(132, 580, 120, 38)
	var box2_bg: Color = Color(0.08, 0.22, 0.12, 0.95) if auto_upg_on else Color(0.06, 0.08, 0.11, 0.85)
	var box2_stroke: Color = Color(0.25, 0.85, 0.45, 0.9) if auto_upg_on else Color(0.25, 0.3, 0.35, 0.5)
	_draw_rounded_rect_filled(box2_rect, 6.0, box2_bg)
	_draw_rounded_rect_stroke(box2_rect, 6.0, box2_stroke, 1.2)
	draw_string(font, Vector2(192, 595), "AUTO UPGRADE", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.85, 0.9, 0.95, 0.9) if auto_upg_on else Color(0.55, 0.6, 0.65, 0.7))
	draw_string(font, Vector2(192, 610), "[ON]" if auto_upg_on else "[OFF]", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.3, 1.0, 0.5, 1.0) if auto_upg_on else Color(0.5, 0.55, 0.6, 0.7))

	# 3. Auto Equip Toggle Button (Rect2(258, 580, 114, 38))
	var box3_rect: Rect2 = Rect2(258, 580, 114, 38)
	var box3_bg: Color = Color(0.08, 0.22, 0.12, 0.95) if auto_eq_on else Color(0.06, 0.08, 0.11, 0.85)
	var box3_stroke: Color = Color(0.25, 0.85, 0.45, 0.9) if auto_eq_on else Color(0.25, 0.3, 0.35, 0.5)
	_draw_rounded_rect_filled(box3_rect, 6.0, box3_bg)
	_draw_rounded_rect_stroke(box3_rect, 6.0, box3_stroke, 1.2)
	draw_string(font, Vector2(315, 595), "AUTO EQUIP", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.85, 0.9, 0.95, 0.9) if auto_eq_on else Color(0.55, 0.6, 0.65, 0.7))
	draw_string(font, Vector2(315, 610), "[ON]" if auto_eq_on else "[OFF]", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.3, 1.0, 0.5, 1.0) if auto_eq_on else Color(0.5, 0.55, 0.6, 0.7))

	# 4. Debug +1h Button (Rect2(378, 580, 70, 38))
	var dbg1_rect: Rect2 = Rect2(378, 580, 70, 38)
	_draw_rounded_rect_filled(dbg1_rect, 6.0, Color(0.18, 0.12, 0.25, 0.9))
	_draw_rounded_rect_stroke(dbg1_rect, 6.0, Color(0.7, 0.4, 0.9, 0.8), 1.0)
	draw_string(font, Vector2(413, 595), "DEBUG", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.8, 0.7, 0.95, 0.8))
	draw_string(font, Vector2(413, 610), "+1h", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1.0, 0.8, 0.3, 1.0))

	# 5. Debug +8h Button (Rect2(454, 580, 74, 38))
	var dbg8_rect: Rect2 = Rect2(454, 580, 74, 38)
	_draw_rounded_rect_filled(dbg8_rect, 6.0, Color(0.22, 0.12, 0.2, 0.9))
	_draw_rounded_rect_stroke(dbg8_rect, 6.0, Color(0.9, 0.4, 0.7, 0.8), 1.0)
	draw_string(font, Vector2(491, 595), "DEBUG", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.95, 0.7, 0.85, 0.8))
	draw_string(font, Vector2(491, 610), "+8h", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1.0, 0.8, 0.3, 1.0))

func _draw_welcome_back() -> void:
	if not show_welcome_back or offline_rewards_data.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	# Dim background
	draw_rect(Rect2(0, 0, 540, 960), Color(0.0, 0.0, 0.0, 0.75))

	var modal_rect: Rect2 = Rect2(50, 240, 440, 310)
	_draw_rounded_rect_filled(modal_rect, 12.0, Color(0.06, 0.08, 0.14, 0.98))
	_draw_rounded_rect_stroke(modal_rect, 12.0, Color(0.95, 0.75, 0.2, 1.0), 2.5)

	# Title
	draw_string(font, Vector2(270, 285), "WELCOME BACK", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color(1.0, 0.88, 0.2, 1.0))

	var elapsed: float = float(offline_rewards_data.get("elapsed", 0.0))
	var hours: int = int(elapsed / 3600.0)
	var mins: int = int(fmod(elapsed, 3600.0) / 60.0)
	var time_str: String = "Offline Duration: " + str(hours) + "h " + str(mins) + "m"
	draw_string(font, Vector2(270, 325), time_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(0.85, 0.92, 1.0, 0.9))

	var g_val: int = int(offline_rewards_data.get("gold", 0))
	draw_string(font, Vector2(270, 365), "Gold Earned: +" + str(g_val), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1.0, 0.85, 0.2, 1.0))

	var eq_val: int = int(offline_rewards_data.get("items_count", 0))
	draw_string(font, Vector2(270, 405), "Equipment Earned: +" + str(eq_val) + " Items", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.7, 0.5, 1.0, 1.0))

	# Claim button
	var btn_rect: Rect2 = Rect2(150, 460, 240, 52)
	_draw_rounded_rect_filled(btn_rect, 8.0, Color(0.15, 0.65, 0.3, 0.95))
	_draw_rounded_rect_stroke(btn_rect, 8.0, Color(0.3, 0.9, 0.5, 1.0), 1.5)

	draw_string(font, Vector2(270, 493), "CLAIM REWARDS", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)

func _draw_rounded_rect_filled(rect: Rect2, r: float, color: Color) -> void:
	var pts: PackedVector2Array = _get_rounded_rect_points(rect, r)
	draw_colored_polygon(pts, color)

func _draw_rounded_rect_stroke(rect: Rect2, r: float, color: Color, width: float = 1.0) -> void:
	var pts: PackedVector2Array = _get_rounded_rect_points(rect, r)
	pts.append(pts[0])
	draw_polyline(pts, color, width, true)

func _get_rounded_rect_points(rect: Rect2, r: float, corner_segments: int = 4) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	var x1: float = rect.position.x + r
	var x2: float = rect.position.x + rect.size.x - r
	var y1: float = rect.position.y + r
	var y2: float = rect.position.y + rect.size.y - r

	# Top-Right corner
	for i: int in range(corner_segments + 1):
		var a: float = -PI/2.0 + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x2 + cos(a) * r, y1 + sin(a) * r))
	# Bottom-Right corner
	for i: int in range(corner_segments + 1):
		var a: float = (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x2 + cos(a) * r, y2 + sin(a) * r))
	# Bottom-Left corner
	for i: int in range(corner_segments + 1):
		var a: float = PI/2.0 + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x1 + cos(a) * r, y2 + sin(a) * r))
	# Top-Left corner
	for i: int in range(corner_segments + 1):
		var a: float = PI + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x1 + cos(a) * r, y1 + sin(a) * r))

	return pts
