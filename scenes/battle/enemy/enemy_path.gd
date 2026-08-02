class_name EnemyPath
extends Node2D

@export var path_points: PackedVector2Array = PackedVector2Array([
	Vector2(475.0, 220.0), # Outer Framing Entry Point (Top-Right)
	Vector2(418.5, 395.1), # Outer Ring Path Intersection
	Vector2(372.5, 422.0), # Mid Ring Path Intersection
	Vector2(330.1, 446.1), # Inner Ring Path Intersection
	Vector2(270.0, 468.0)  # Central Defender Platform Destination
])

@export var draw_path_guide: bool = false

func _ready() -> void:
	pass

func get_points() -> PackedVector2Array:
	return path_points

func _draw() -> void:
	if not draw_path_guide or path_points.size() < 2:
		return

	# Draw subtle path guide line for visual testing verification
	draw_polyline(path_points, Color(0.9, 0.3, 0.3, 0.35), 2.0, true)

	# Draw waypoint node markers
	for i: int in range(path_points.size()):
		var pt: Vector2 = path_points[i]
		if i == 0:
			# Entry point marker
			draw_circle(pt, 5.0, Color(0.95, 0.4, 0.2, 0.8))
		elif i == path_points.size() - 1:
			# Central platform destination marker
			draw_circle(pt, 6.0, Color(0.95, 0.8, 0.2, 0.9))
		else:
			# Intermediate waypoint marker
			draw_circle(pt, 3.5, Color(0.9, 0.3, 0.3, 0.6))
