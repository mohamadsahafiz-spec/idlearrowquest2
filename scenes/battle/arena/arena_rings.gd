class_name ArenaRings
extends Node2D

@export var center: Vector2 = Vector2(270, 480)

# Isometric ring radii
@export var outer_ring_rx: float = 210.0
@export var outer_ring_ry: float = 120.0

@export var mid_ring_rx: float = 145.0
@export var mid_ring_ry: float = 82.0

@export var inner_ring_rx: float = 85.0
@export var inner_ring_ry: float = 48.0

func _draw() -> void:
	# Outer defense ring (Main enemy approach path)
	_draw_ring_path(center, outer_ring_rx, outer_ring_ry, Color(0.2, 0.55, 0.75, 0.8), Color(0.1, 0.3, 0.45, 0.35), 16.0)
	_draw_ellipse_stroke(center, outer_ring_rx + 8, outer_ring_ry + 5, Color(0.3, 0.7, 0.9, 0.5), 1.5)
	_draw_ellipse_stroke(center, outer_ring_rx - 8, outer_ring_ry - 5, Color(0.3, 0.7, 0.9, 0.5), 1.5)

	# Mid defense ring (Secondary line)
	_draw_ring_path(center, mid_ring_rx, mid_ring_ry, Color(0.8, 0.6, 0.2, 0.8), Color(0.4, 0.3, 0.1, 0.3), 12.0)
	_draw_dashed_ellipse(center, mid_ring_rx, mid_ring_ry, Color(0.95, 0.75, 0.3, 0.7), 2.0, 24)

	# Inner defense ring (Platform moat/perimeter)
	_draw_ellipse_filled(center, inner_ring_rx, inner_ring_ry, Color(0.15, 0.22, 0.28, 0.9))
	_draw_ellipse_stroke(center, inner_ring_rx, inner_ring_ry, Color(0.3, 0.85, 0.6, 0.85), 2.5)

	# Radial path markers (Connecting outer ring to inner ring)
	var angles: Array[float] = [0.0, PI/4, PI/2, 3*PI/4, PI, 5*PI/4, 3*PI/2, 7*PI/4]
	for a: float in angles:
		var start_p: Vector2 = center + Vector2(cos(a) * inner_ring_rx, sin(a) * inner_ring_ry)
		var end_p: Vector2 = center + Vector2(cos(a) * outer_ring_rx, sin(a) * outer_ring_ry)
		draw_line(start_p, end_p, Color(0.4, 0.6, 0.75, 0.3), 1.5, true)
		
		# Draw node markers at outer ring intersections
		draw_circle(end_p, 4.0, Color(0.3, 0.8, 1.0, 0.9))
		draw_circle(end_p, 2.0, Color(1.0, 1.0, 1.0, 1.0))

func _draw_ring_path(pos: Vector2, rx: float, ry: float, stroke_color: Color, fill_color: Color, path_width: float) -> void:
	_draw_ellipse_stroke(pos, rx, ry, fill_color, path_width)
	_draw_ellipse_stroke(pos, rx, ry, stroke_color, 1.5)

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 48) -> void:
	var pts := PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)

func _draw_ellipse_stroke(pos: Vector2, rx: float, ry: float, color: Color, width: float = 1.0, segments: int = 48) -> void:
	var pts := PackedVector2Array()
	for i: int in range(segments + 1):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, width, true)

func _draw_dashed_ellipse(pos: Vector2, rx: float, ry: float, color: Color, width: float, dashes: int = 24) -> void:
	for i: int in range(dashes):
		if i % 2 == 0:
			var a1: float = float(i) * TAU / float(dashes)
			var a2: float = float(i + 0.7) * TAU / float(dashes)
			_draw_arc_ellipse(pos, rx, ry, a1, a2, color, width)

func _draw_arc_ellipse(pos: Vector2, rx: float, ry: float, angle_start: float, angle_end: float, color: Color, width: float, segments: int = 8) -> void:
	var pts := PackedVector2Array()
	for i: int in range(segments + 1):
		var t: float = float(i) / float(segments)
		var a: float = lerpf(angle_start, angle_end, t)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, width, true)
