class_name HUDPlaceholder
extends Control

var kill_count: int = 0

func update_kill_count(count: int) -> void:
	kill_count = count
	queue_redraw()

func _draw() -> void:
	# Top HUD Header Area Placeholder (y: 0 to 105)
	var top_bar: Rect2 = Rect2(0, 0, 540, 105)
	draw_rect(top_bar, Color(0.05, 0.07, 0.1, 0.85))
	draw_line(Vector2(0, 105), Vector2(540, 105), Color(0.2, 0.35, 0.5, 0.8), 2.0)

	# Kill Counter Badge Display
	var badge_rect: Rect2 = Rect2(20, 32, 175, 38)
	_draw_rounded_rect_filled(badge_rect, 6.0, Color(0.08, 0.12, 0.18, 0.85))
	_draw_rounded_rect_stroke(badge_rect, 6.0, Color(0.25, 0.4, 0.6, 0.7), 1.5)

	var font: Font = ThemeDB.fallback_font
	if font != null:
		var kill_text: String = "Kill Enemies: " + str(kill_count)
		# Drop shadow
		draw_string(font, Vector2(33, 57), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.0, 0.0, 0.0, 0.85))
		# Main HUD text
		draw_string(font, Vector2(32, 56), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.92, 0.96, 1.0, 0.95))

	# Bottom Navigation / Skill Area Placeholder (y: 750 to 960)
	var bottom_bar: Rect2 = Rect2(0, 750, 540, 210)
	draw_rect(bottom_bar, Color(0.05, 0.07, 0.1, 0.9))
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)

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
