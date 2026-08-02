class_name ArenaFraming
extends Node2D

@export var center: Vector2 = Vector2(270, 480)

# Four framing environmental corner pillars
var corner_positions := [
	Vector2(65, 220),   # Top Left
	Vector2(475, 220),  # Top Right
	Vector2(65, 710),   # Bottom Left
	Vector2(475, 710)   # Bottom Right
]

func _draw() -> void:
	# Environmental framing arches / boundary guides
	_draw_framing_arch(Vector2(270, 145), 230.0, 30.0, Color(0.2, 0.3, 0.4, 0.4))
	_draw_framing_arch(Vector2(270, 755), 230.0, 30.0, Color(0.2, 0.3, 0.4, 0.4))

	# Corner Pillars / Torches / Structure Placeholders
	for p in corner_positions:
		_draw_corner_pillar(p)

func _draw_corner_pillar(pos: Vector2) -> void:
	# Shadow
	_draw_ellipse_filled(pos + Vector2(0, 12), 18.0, 10.0, Color(0.02, 0.04, 0.06, 0.5))
	
	# Base pedestal
	var pts_base := PackedVector2Array([
		pos + Vector2(-16, 8),
		pos + Vector2(16, 8),
		pos + Vector2(12, -4),
		pos + Vector2(-12, -4)
	])
	draw_colored_polygon(pts_base, Color(0.18, 0.22, 0.3, 1.0))
	_draw_polyline_closed(pts_base, Color(0.3, 0.4, 0.5, 0.7), 1.0)

	# Column body
	var pts_col := PackedVector2Array([
		pos + Vector2(-10, -4),
		pos + Vector2(10, -4),
		pos + Vector2(8, -32),
		pos + Vector2(-8, -32)
	])
	draw_colored_polygon(pts_col, Color(0.24, 0.28, 0.38, 1.0))
	_draw_polyline_closed(pts_col, Color(0.4, 0.5, 0.6, 0.8), 1.0)

	# Top Ember/Crystal Cap
	var cap_pos := pos + Vector2(0, -36)
	_draw_ellipse_filled(cap_pos, 10.0, 6.0, Color(0.2, 0.5, 0.7, 0.9))
	_draw_ellipse_stroke(cap_pos, 10.0, 6.0, Color(0.4, 0.8, 1.0, 0.9), 1.5)
	
	# Light aura
	draw_circle(cap_pos, 4.0, Color(0.6, 0.9, 1.0, 0.9))

func _draw_framing_arch(pos: Vector2, rx: float, ry: float, color: Color) -> void:
	var pts := PackedVector2Array()
	var segments := 32
	for i in range(segments + 1):
		var a := float(i) / segments * PI
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, 1.5, true)

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 24) -> void:
	var pts := PackedVector2Array()
	for i in range(segments):
		var a := i * TAU / segments
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)

func _draw_ellipse_stroke(pos: Vector2, rx: float, ry: float, color: Color, width: float = 1.0, segments: int = 24) -> void:
	var pts := PackedVector2Array()
	for i in range(segments + 1):
		var a := i * TAU / segments
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, width, true)

func _draw_polyline_closed(pts: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	var closed_pts := pts.duplicate()
	closed_pts.append(pts[0])
	draw_polyline(closed_pts, color, width, true)
