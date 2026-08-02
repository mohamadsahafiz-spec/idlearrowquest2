class_name EnemyPlaceholder
extends Node2D

signal reached_destination

@export var speed: float = 85.0
@export var enemy_color: Color = Color(0.95, 0.25, 0.25, 1.0)
@export var outline_color: Color = Color(1.0, 0.85, 0.85, 0.9)
@export var radius: float = 10.0

var path_points: PackedVector2Array = PackedVector2Array()
var current_waypoint_index: int = 0
var is_moving: bool = false

func _ready() -> void:
	pass

func start_path(points: PackedVector2Array) -> void:
	path_points = points
	if path_points.size() > 0:
		position = path_points[0]
		current_waypoint_index = 1
		is_moving = true
	else:
		is_moving = false

func _process(delta: float) -> void:
	if not is_moving or current_waypoint_index >= path_points.size():
		return

	var target_pos: Vector2 = path_points[current_waypoint_index]
	var distance_to_target: float = position.distance_to(target_pos)
	var move_distance: float = speed * delta

	if move_distance >= distance_to_target:
		position = target_pos
		current_waypoint_index += 1
		if current_waypoint_index >= path_points.size():
			is_moving = false
			reached_destination.emit()
	else:
		var direction: Vector2 = (target_pos - position).normalized()
		position += direction * move_distance

	queue_redraw()

func _draw() -> void:
	# Ground Shadow
	var shadow_pos: Vector2 = Vector2(0, 8)
	_draw_ellipse_filled(shadow_pos, radius * 1.2, radius * 0.6, Color(0.02, 0.04, 0.06, 0.5))

	# Enemy Body (Stylized primitive diamond/orb)
	var pts: PackedVector2Array = PackedVector2Array([
		Vector2(0, -radius * 1.3),
		Vector2(radius, 0),
		Vector2(0, radius * 0.9),
		Vector2(-radius, 0)
	])
	draw_colored_polygon(pts, enemy_color)
	_draw_polyline_closed(pts, outline_color, 2.0)

	# Core Glow Center
	draw_circle(Vector2(0, -radius * 0.2), radius * 0.4, Color(1.0, 0.9, 0.4, 0.95))

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 24) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)

func _draw_polyline_closed(pts: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	var closed_pts: PackedVector2Array = pts.duplicate()
	closed_pts.append(pts[0])
	draw_polyline(closed_pts, color, width, true)
