class_name CentralPlatform
extends Node2D

@export var center: Vector2 = Vector2(270, 480)

# Multi-tier podium dimensions
@export var tier1_rx: float = 65.0
@export var tier1_ry: float = 36.0
@export var tier1_height: float = 14.0

@export var tier2_rx: float = 48.0
@export var tier2_ry: float = 27.0
@export var tier2_height: float = 12.0

@export var top_pad_rx: float = 34.0
@export var top_pad_ry: float = 19.0

func _draw() -> void:
	# Ground Shadow
	_draw_ellipse_filled(center + Vector2(0, 10), tier1_rx + 8, tier1_ry + 5, Color(0.02, 0.04, 0.06, 0.6))

	# Tier 1 Base (Isometric 3D extrusion)
	var t1_base_pos: Vector2 = center
	var t1_top_pos: Vector2 = center - Vector2(0, tier1_height)
	_draw_isometric_cylinder(t1_base_pos, t1_top_pos, tier1_rx, tier1_ry, Color(0.2, 0.24, 0.32, 1.0), Color(0.28, 0.34, 0.44, 1.0), Color(0.4, 0.5, 0.65, 0.8))

	# Tier 2 Pedestal
	var t2_base_pos: Vector2 = t1_top_pos
	var t2_top_pos: Vector2 = t2_base_pos - Vector2(0, tier2_height)
	_draw_isometric_cylinder(t2_base_pos, t2_top_pos, tier2_rx, tier2_ry, Color(0.25, 0.3, 0.38, 1.0), Color(0.35, 0.42, 0.52, 1.0), Color(0.8, 0.65, 0.25, 0.9))

	# Top Defender / Tower Placement Pad
	_draw_ellipse_filled(t2_top_pos, top_pad_rx, top_pad_ry, Color(0.18, 0.22, 0.3, 1.0))
	_draw_ellipse_stroke(t2_top_pos, top_pad_rx, top_pad_ry, Color(0.9, 0.75, 0.3, 1.0), 2.0)
	_draw_ellipse_stroke(t2_top_pos, top_pad_rx - 5, top_pad_ry - 3, Color(0.3, 0.85, 0.95, 0.8), 1.5)

	# Central Defender / Tower Platform Anchor Diamond Icon
	var p_top: Vector2 = t2_top_pos
	var diamond := PackedVector2Array([
		p_top + Vector2(0, -10),
		p_top + Vector2(12, 0),
		p_top + Vector2(0, 7),
		p_top + Vector2(-12, 0)
	])
	draw_colored_polygon(diamond, Color(0.95, 0.8, 0.3, 0.85))
	_draw_polyline_closed(diamond, Color(1.0, 1.0, 1.0, 0.9), 1.5)

func _draw_isometric_cylinder(base_pos: Vector2, top_pos: Vector2, rx: float, ry: float, side_color: Color, top_color: Color, rim_color: Color) -> void:
	# Draw front half of side wall
	var segments: int = 32
	var side_pts := PackedVector2Array()
	
	# Bottom half arc (0 to PI)
	for i: int in range(segments + 1):
		var a: float = float(i) / float(segments) * PI
		side_pts.append(base_pos + Vector2(cos(a) * rx, sin(a) * ry))
	# Top half arc reversed (PI to 0)
	for i: int in range(segments + 1):
		var a: float = PI - (float(i) / float(segments) * PI)
		side_pts.append(top_pos + Vector2(cos(a) * rx, sin(a) * ry))
		
	draw_colored_polygon(side_pts, side_color)
	
	# Top surface
	_draw_ellipse_filled(top_pos, rx, ry, top_color)
	_draw_ellipse_stroke(top_pos, rx, ry, rim_color, 1.5)

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 36) -> void:
	var pts := PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)

func _draw_ellipse_stroke(pos: Vector2, rx: float, ry: float, color: Color, width: float = 1.0, segments: int = 36) -> void:
	var pts := PackedVector2Array()
	for i: int in range(segments + 1):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, width, true)

func _draw_polyline_closed(pts: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	var closed_pts := pts.duplicate()
	closed_pts.append(pts[0])
	draw_polyline(closed_pts, color, width, true)
