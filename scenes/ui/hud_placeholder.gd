class_name HUDPlaceholder
extends Control

var kill_count: int = 0
var current_stage: int = 1
var current_wave: int = 1
var total_waves: int = 3
var wave_kills: int = 0
var wave_required_kills: int = 5
var banner_text: String = ""

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

func _draw() -> void:
	# Top HUD Header Area Placeholder (y: 0 to 105)
	var top_bar: Rect2 = Rect2(0, 0, 540, 105)
	draw_rect(top_bar, Color(0.05, 0.07, 0.1, 0.85))
	draw_line(Vector2(0, 105), Vector2(540, 105), Color(0.2, 0.35, 0.5, 0.8), 2.0)

	# Left: Total Kills Badge
	var kill_badge_rect: Rect2 = Rect2(16, 28, 160, 48)
	_draw_rounded_rect_filled(kill_badge_rect, 6.0, Color(0.08, 0.12, 0.18, 0.85))
	_draw_rounded_rect_stroke(kill_badge_rect, 6.0, Color(0.25, 0.4, 0.6, 0.7), 1.5)

	var font: Font = ThemeDB.fallback_font
	if font != null:
		var kill_text: String = "Kill Enemies: " + str(kill_count)
		draw_string(font, Vector2(27, 57), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.0, 0.0, 0.0, 0.85))
		draw_string(font, Vector2(26, 56), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.92, 0.96, 1.0, 0.95))

	# Right: Stage & Wave Info Badge
	var stage_badge_rect: Rect2 = Rect2(310, 18, 214, 70)
	_draw_rounded_rect_filled(stage_badge_rect, 8.0, Color(0.06, 0.1, 0.16, 0.92))
	_draw_rounded_rect_stroke(stage_badge_rect, 8.0, Color(0.3, 0.5, 0.75, 0.8), 1.5)

	if font != null:
		var stage_str: String = "Stage " + str(current_stage)
		var wave_str: String = "Wave " + str(current_wave) + " / " + str(total_waves)
		var enemies_str: String = "Enemies " + str(wave_kills) + " / " + str(wave_required_kills)

		# Stage Title
		draw_string(font, Vector2(322, 38), stage_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.0, 0.0, 0.0, 0.8))
		draw_string(font, Vector2(321, 37), stage_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.9, 0.4, 1.0))

		# Wave Count
		draw_string(font, Vector2(322, 58), wave_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.0, 0.0, 0.0, 0.8))
		draw_string(font, Vector2(321, 57), wave_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.85, 0.92, 1.0, 0.95))

		# Enemies Count
		draw_string(font, Vector2(322, 76), enemies_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.0, 0.0, 0.0, 0.8))
		draw_string(font, Vector2(321, 75), enemies_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.75, 0.88, 0.98, 0.95))

	# Center Transition / Announcement Banner
	if not banner_text.is_empty():
		_draw_banner_overlay()

	# Bottom Navigation / Skill Area Placeholder (y: 750 to 960)
	var bottom_bar: Rect2 = Rect2(0, 750, 540, 210)
	draw_rect(bottom_bar, Color(0.05, 0.07, 0.1, 0.9))
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)

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
