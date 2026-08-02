class_name DevPanel
extends Control

signal close_requested()

var battle: Battle = null
var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null
var maid_system: MaidSystem = null
var save_system: SaveSystem = null
var arena_placeholder: ArenaPlaceholder = null

var show_confirm_reset_save: bool = false

func _ready() -> void:
	z_index = 100
	mouse_filter = MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = event.position

		# Close button
		if Rect2(470, 90, 40, 36).has_point(pos):
			visible = false
			show_confirm_reset_save = false
			close_requested.emit()
			accept_event()
			queue_redraw()
			return

		if show_confirm_reset_save:
			# Confirm Delete Save
			if Rect2(80, 710, 180, 40).has_point(pos):
				if save_system != null:
					save_system.delete_save_file()
				if battle != null:
					battle.reset_to_fresh_state()
				show_confirm_reset_save = false
				visible = false
				accept_event()
				queue_redraw()
				return
			# Cancel Delete Save
			elif Rect2(280, 710, 180, 40).has_point(pos):
				show_confirm_reset_save = false
				accept_event()
				queue_redraw()
				return
			# Block input on dialog
			if Rect2(60, 620, 420, 150).has_point(pos):
				accept_event()
				return

		# 1. PARTY SIZE (1-6)
		for i in range(1, 7):
			var rect: Rect2 = Rect2(40 + (i - 1) * 75, 145, 65, 36)
			if rect.has_point(pos):
				if maid_system != null:
					maid_system.debug_set_party_count(i)
				accept_event()
				queue_redraw()
				return

		# Heal All
		if Rect2(40, 190, 140, 36).has_point(pos):
			if arena_placeholder != null:
				for m: DefenderPlaceholder in arena_placeholder.active_maids:
					if is_instance_valid(m):
						m.current_hp = m.max_hp
						m.hp_changed.emit(m.current_hp, m.max_hp)
			accept_event()
			queue_redraw()
			return

		# Kill Maid
		if Rect2(190, 190, 140, 36).has_point(pos):
			if arena_placeholder != null:
				var m: DefenderPlaceholder = arena_placeholder.get_alive_defender()
				if m != null:
					m.take_damage(9999999.0)
			accept_event()
			queue_redraw()
			return

		# Kill All
		if Rect2(340, 190, 140, 36).has_point(pos):
			if arena_placeholder != null:
				for m: DefenderPlaceholder in arena_placeholder.active_maids:
					if is_instance_valid(m) and m.current_hp > 0.0:
						m.take_damage(9999999.0)
			accept_event()
			queue_redraw()
			return

		# 2. WORLD SELECT (W1 - W6)
		for w in range(1, 7):
			var rect: Rect2 = Rect2(40 + (w - 1) * 75, 255, 65, 36)
			if rect.has_point(pos):
				if stage_system != null:
					stage_system.start_stage(1, w)
				accept_event()
				queue_redraw()
				return

		# Stage Adjustments
		if Rect2(40, 300, 80, 36).has_point(pos):
			if stage_system != null:
				stage_system.start_stage(max(1, stage_system.current_stage - 1), stage_system.current_world)
			accept_event()
			queue_redraw()
			return
		elif Rect2(130, 300, 80, 36).has_point(pos):
			if stage_system != null:
				stage_system.start_stage(stage_system.current_stage + 1, stage_system.current_world)
			accept_event()
			queue_redraw()
			return
		elif Rect2(220, 300, 80, 36).has_point(pos):
			if stage_system != null:
				stage_system.start_stage(5, stage_system.current_world)
			accept_event()
			queue_redraw()
			return
		elif Rect2(310, 300, 80, 36).has_point(pos):
			if stage_system != null:
				stage_system.start_stage(10, stage_system.current_world)
			accept_event()
			queue_redraw()
			return
		elif Rect2(400, 300, 80, 36).has_point(pos):
			if stage_system != null:
				var max_s: int = WorldRegistry.get_max_stages(stage_system.current_world)
				stage_system.start_stage(max_s, stage_system.current_world)
			accept_event()
			queue_redraw()
			return

		# Force Boss
		if Rect2(40, 345, 140, 36).has_point(pos):
			if stage_system != null:
				stage_system.state = StageSystem.State.BOSS_INCOMING
				stage_system.state_timer = 0.05
				stage_system.banner_text = "BOSS INCOMING"
				stage_system.banner_text_changed.emit("BOSS INCOMING")
			accept_event()
			queue_redraw()
			return

		# Clear Stage
		if Rect2(190, 345, 140, 36).has_point(pos):
			if stage_system != null:
				stage_system.notify_enemy_killed(stage_system.state == StageSystem.State.BOSS_ACTIVE)
			accept_event()
			queue_redraw()
			return

		# Clear World
		if Rect2(340, 345, 140, 36).has_point(pos):
			if stage_system != null:
				var max_s: int = WorldRegistry.get_max_stages(stage_system.current_world)
				stage_system.start_stage(max_s, stage_system.current_world)
				stage_system._on_boss_killed()
			accept_event()
			queue_redraw()
			return

		# Endless Mode
		if Rect2(40, 390, 440, 36).has_point(pos):
			if stage_system != null:
				stage_system.is_endless_mode = not stage_system.is_endless_mode
				stage_system.start_stage(501, 6)
			accept_event()
			queue_redraw()
			return

		# 3. ECONOMY / COMBAT
		# +10K Gold
		if Rect2(40, 455, 100, 36).has_point(pos):
			if progression_system != null:
				progression_system.add_gold(10000)
			accept_event()
			queue_redraw()
			return
		# +1M Gold
		elif Rect2(150, 455, 100, 36).has_point(pos):
			if progression_system != null:
				progression_system.add_gold(1000000)
			accept_event()
			queue_redraw()
			return
		# Set Gold 0
		elif Rect2(260, 455, 100, 36).has_point(pos):
			if progression_system != null:
				progression_system.gold = 0
				progression_system.gold_changed.emit(0)
			accept_event()
			queue_redraw()
			return
		# Set 100K
		elif Rect2(370, 455, 110, 36).has_point(pos):
			if progression_system != null:
				progression_system.gold = 100000
				progression_system.gold_changed.emit(100000)
			accept_event()
			queue_redraw()
			return

		# Restore HP
		if Rect2(40, 500, 140, 36).has_point(pos):
			if arena_placeholder != null:
				for m: DefenderPlaceholder in arena_placeholder.active_maids:
					if is_instance_valid(m):
						m.current_hp = m.max_hp
						m.hp_changed.emit(m.current_hp, m.max_hp)
			accept_event()
			queue_redraw()
			return

		# Reset Upgrades
		if Rect2(190, 500, 140, 36).has_point(pos):
			if progression_system != null:
				progression_system.attack_level = 1
				progression_system.speed_level = 1
				progression_system.crit_level = 1
				progression_system.hp_level = 1
				progression_system.upgrade_applied.emit("all", 1)
			accept_event()
			queue_redraw()
			return

		# Fresh Baseline
		if Rect2(340, 500, 140, 36).has_point(pos):
			if progression_system != null:
				progression_system.attack_level = 1
				progression_system.speed_level = 1
				progression_system.crit_level = 1
				progression_system.hp_level = 1
				progression_system.gold = 100
				progression_system.gold_changed.emit(100)
				progression_system.upgrade_applied.emit("all", 1)
			if equipment_system != null:
				equipment_system.inventory.clear()
				equipment_system.equipped.clear()
				equipment_system.inventory_changed.emit()
			accept_event()
			queue_redraw()
			return

		# 4. RESET & ISOLATION
		# Reset Test/Run
		if Rect2(40, 565, 215, 42).has_point(pos):
			if arena_placeholder != null:
				arena_placeholder.reset_arena()
			if stage_system != null:
				stage_system.start_stage(1, 1)
			accept_event()
			queue_redraw()
			return

		# Reset Save File
		if Rect2(265, 565, 215, 42).has_point(pos):
			show_confirm_reset_save = true
			accept_event()
			queue_redraw()
			return

		# Block clicking through panel
		if Rect2(20, 80, 500, 800).has_point(pos):
			accept_event()
			return

func _draw() -> void:
	if not visible:
		return

	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	# Modal panel background
	var panel_rect: Rect2 = Rect2(20, 80, 500, 800)
	_draw_rounded_rect_filled(panel_rect, 12.0, Color(0.05, 0.07, 0.12, 0.98))
	_draw_rounded_rect_stroke(panel_rect, 12.0, Color(0.9, 0.35, 0.35, 0.95), 2.0)

	# Title
	draw_string(font, Vector2(270, 110), "DEVELOPER SUITE (DEBUG)", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1.0, 0.4, 0.4, 1.0))

	# Close Button
	var close_rect: Rect2 = Rect2(470, 90, 40, 36)
	_draw_rounded_rect_filled(close_rect, 6.0, Color(0.3, 0.1, 0.1, 0.9))
	_draw_rounded_rect_stroke(close_rect, 6.0, Color(0.9, 0.3, 0.3, 0.9), 1.0)
	draw_string(font, Vector2(490, 113), "X", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

	# 1. PARTY SIZE CONTROLS
	draw_string(font, Vector2(40, 138), "PARTY SIZE (1 - 6):", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.85, 0.9, 0.9))
	var active_count: int = 1
	if maid_system != null:
		active_count = maid_system.get_active_party_count()
	for i in range(1, 7):
		var rect: Rect2 = Rect2(40 + (i - 1) * 75, 145, 65, 36)
		var is_sel: bool = (i == active_count)
		var bg: Color = Color(0.1, 0.4, 0.25, 0.95) if is_sel else Color(0.1, 0.15, 0.22, 0.9)
		var stroke: Color = Color(0.3, 0.9, 0.5, 1.0) if is_sel else Color(0.25, 0.35, 0.45, 0.6)
		_draw_rounded_rect_filled(rect, 6.0, bg)
		_draw_rounded_rect_stroke(rect, 6.0, stroke, 1.2)
		draw_string(font, Vector2(rect.position.x + 32, rect.position.y + 22), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color.WHITE)

	# Party Actions
	_draw_btn(Rect2(40, 190, 140, 36), "HEAL ALL", Color(0.1, 0.3, 0.2, 0.9), Color(0.3, 0.8, 0.4, 0.9))
	_draw_btn(Rect2(190, 190, 140, 36), "KILL MAID", Color(0.3, 0.2, 0.1, 0.9), Color(0.9, 0.5, 0.2, 0.9))
	_draw_btn(Rect2(340, 190, 140, 36), "KILL ALL", Color(0.4, 0.1, 0.1, 0.9), Color(0.9, 0.2, 0.2, 0.9))

	# 2. WORLD / STAGE CONTROLS
	draw_string(font, Vector2(40, 248), "WORLD / STAGE OVERRIDE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.85, 0.9, 0.9))
	var cur_w: int = stage_system.current_world if stage_system != null else 1
	for w in range(1, 7):
		var rect: Rect2 = Rect2(40 + (w - 1) * 75, 255, 65, 36)
		var is_sel: bool = (w == cur_w)
		var bg: Color = Color(0.2, 0.35, 0.5, 0.95) if is_sel else Color(0.1, 0.15, 0.22, 0.9)
		var stroke: Color = Color(0.4, 0.7, 1.0, 1.0) if is_sel else Color(0.25, 0.35, 0.45, 0.6)
		_draw_rounded_rect_filled(rect, 6.0, bg)
		_draw_rounded_rect_stroke(rect, 6.0, stroke, 1.2)
		draw_string(font, Vector2(rect.position.x + 32, rect.position.y + 22), "W" + str(w), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)

	_draw_btn(Rect2(40, 300, 80, 36), "-1 STG", Color(0.12, 0.16, 0.24, 0.9), Color(0.4, 0.5, 0.6, 0.8))
	_draw_btn(Rect2(130, 300, 80, 36), "+1 STG", Color(0.12, 0.16, 0.24, 0.9), Color(0.4, 0.5, 0.6, 0.8))
	_draw_btn(Rect2(220, 300, 80, 36), "STG 5", Color(0.12, 0.16, 0.24, 0.9), Color(0.4, 0.5, 0.6, 0.8))
	_draw_btn(Rect2(310, 300, 80, 36), "STG 10", Color(0.12, 0.16, 0.24, 0.9), Color(0.4, 0.5, 0.6, 0.8))
	_draw_btn(Rect2(400, 300, 80, 36), "MAX STG", Color(0.12, 0.16, 0.24, 0.9), Color(0.4, 0.5, 0.6, 0.8))

	_draw_btn(Rect2(40, 345, 140, 36), "FORCE BOSS", Color(0.35, 0.1, 0.25, 0.9), Color(0.9, 0.3, 0.6, 0.9))
	_draw_btn(Rect2(190, 345, 140, 36), "CLEAR STAGE", Color(0.1, 0.25, 0.35, 0.9), Color(0.3, 0.7, 0.9, 0.9))
	_draw_btn(Rect2(340, 345, 140, 36), "CLEAR WORLD", Color(0.2, 0.1, 0.35, 0.9), Color(0.7, 0.4, 0.9, 0.9))
	var endless_on: bool = stage_system.is_endless_mode if stage_system != null else false
	_draw_btn(Rect2(40, 390, 440, 36), "ENDLESS MODE: " + ("[ON - STG 501]" if endless_on else "[OFF]"), Color(0.3, 0.2, 0.05, 0.9) if endless_on else Color(0.12, 0.15, 0.2, 0.9), Color(0.9, 0.7, 0.2, 0.9) if endless_on else Color(0.4, 0.45, 0.5, 0.8))

	# 3. ECONOMY / COMBAT
	draw_string(font, Vector2(40, 448), "ECONOMY & COMBAT BASELINE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.85, 0.9, 0.9))
	_draw_btn(Rect2(40, 455, 100, 36), "+10K GOLD", Color(0.25, 0.2, 0.05, 0.9), Color(0.9, 0.75, 0.2, 0.9))
	_draw_btn(Rect2(150, 455, 100, 36), "+1M GOLD", Color(0.3, 0.22, 0.05, 0.9), Color(1.0, 0.85, 0.2, 0.9))
	_draw_btn(Rect2(260, 455, 100, 36), "SET GOLD 0", Color(0.18, 0.12, 0.12, 0.9), Color(0.6, 0.4, 0.4, 0.8))
	_draw_btn(Rect2(370, 455, 110, 36), "SET 100K", Color(0.2, 0.18, 0.08, 0.9), Color(0.8, 0.7, 0.3, 0.8))

	_draw_btn(Rect2(40, 500, 140, 36), "RESTORE HP", Color(0.1, 0.28, 0.2, 0.9), Color(0.3, 0.8, 0.5, 0.9))
	_draw_btn(Rect2(190, 500, 140, 36), "RESET UPGRADES", Color(0.2, 0.15, 0.25, 0.9), Color(0.7, 0.5, 0.8, 0.9))
	_draw_btn(Rect2(340, 500, 140, 36), "FRESH BASELINE", Color(0.25, 0.15, 0.1, 0.9), Color(0.8, 0.5, 0.3, 0.9))

	# 4. RESET & ISOLATION
	draw_string(font, Vector2(40, 558), "RESET & SAVE ISOLATION:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.85, 0.9, 0.9))
	_draw_btn(Rect2(40, 565, 215, 42), "RESET TEST RUN (TEMP)", Color(0.1, 0.2, 0.3, 0.9), Color(0.3, 0.6, 0.9, 0.9))
	_draw_btn(Rect2(265, 565, 215, 42), "RESET SAVE FILE (PERM)", Color(0.4, 0.1, 0.1, 0.95), Color(1.0, 0.3, 0.3, 1.0))

	# Confirmation Dialog Overlay
	if show_confirm_reset_save:
		var dialog_rect: Rect2 = Rect2(60, 620, 420, 150)
		_draw_rounded_rect_filled(dialog_rect, 10.0, Color(0.12, 0.02, 0.02, 0.98))
		_draw_rounded_rect_stroke(dialog_rect, 10.0, Color(1.0, 0.2, 0.2, 1.0), 2.0)

		draw_string(font, Vector2(270, 650), "PERMANENTLY ERASE SAVE?", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(1.0, 0.3, 0.3, 1.0))
		draw_string(font, Vector2(270, 675), "This will delete all persistent progress!", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.9, 0.8, 0.8, 0.9))

		_draw_btn(Rect2(80, 710, 180, 40), "CONFIRM ERASE", Color(0.6, 0.1, 0.1, 0.95), Color(1.0, 0.3, 0.3, 1.0))
		_draw_btn(Rect2(280, 710, 180, 40), "CANCEL", Color(0.15, 0.2, 0.25, 0.95), Color(0.5, 0.6, 0.7, 0.9))

func _draw_btn(rect: Rect2, label: String, bg: Color, stroke: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	_draw_rounded_rect_filled(rect, 6.0, bg)
	_draw_rounded_rect_stroke(rect, 6.0, stroke, 1.0)
	draw_string(font, Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * 0.5 + 4), label, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color.WHITE)

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

	for i in range(corner_segments + 1):
		var a: float = -PI/2.0 + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x2 + cos(a) * r, y1 + sin(a) * r))
	for i in range(corner_segments + 1):
		var a: float = (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x2 + cos(a) * r, y2 + sin(a) * r))
	for i in range(corner_segments + 1):
		var a: float = PI/2.0 + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x1 + cos(a) * r, y2 + sin(a) * r))
	for i in range(corner_segments + 1):
		var a: float = PI + (float(i) / float(corner_segments)) * (PI/2.0)
		pts.append(Vector2(x1 + cos(a) * r, y1 + sin(a) * r))

	return pts
