class_name ArenaBackground
extends Node2D

@export var center: Vector2 = Vector2(270, 480)
@export var outer_rx: float = 230.0
@export var outer_ry: float = 135.0

func _draw() -> void:
	# Base dark background gradient/fill
	var bg_rect: Rect2 = Rect2(0, 0, 540, 960)
	draw_rect(bg_rect, Color(0.06, 0.08, 0.12, 1.0))
	
	# Arena battle zone field (y: 110 to 750)
	var battle_zone: Rect2 = Rect2(0, 110, 540, 640)
	draw_rect(battle_zone, Color(0.08, 0.11, 0.16, 1.0))
	
	# Soft radial ambient ground floor
	_draw_ellipse_filled(center, outer_rx + 15, outer_ry + 10, Color(0.04, 0.06, 0.09, 0.8))
	_draw_ellipse_filled(center, outer_rx, outer_ry, Color(0.12, 0.16, 0.22, 1.0))
	_draw_ellipse_filled(center, outer_rx - 12, outer_ry - 8, Color(0.14, 0.19, 0.26, 1.0))

	# Subtle grid / concentric ground floor lines
	for i: int in range(1, 4):
		var scale_factor: float = float(i) / 4.0
		_draw_ellipse_stroke(center, outer_rx * scale_factor, outer_ry * scale_factor, Color(0.2, 0.26, 0.35, 0.35), 1.0)

	# Boundary vignette ring
	_draw_ellipse_stroke(center, outer_rx, outer_ry, Color(0.25, 0.35, 0.45, 0.6), 2.0)

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
