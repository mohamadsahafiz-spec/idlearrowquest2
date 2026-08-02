class_name DefenderPlaceholder
extends Node2D

@export var detection_range: float = 240.0
@export var fire_cooldown: float = 0.8
@export var enemies_container: Node2D
@export var projectiles_container: Node2D

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/battle/projectile/projectile_placeholder.tscn")

var current_target: EnemyPlaceholder = null
var fire_timer: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_update_target()
	_update_firing(delta)
	queue_redraw()

func _update_firing(delta: float) -> void:
	if current_target != null and is_instance_valid(current_target):
		fire_timer -= delta
		if fire_timer <= 0.0:
			_fire_projectile()
			fire_timer = fire_cooldown
	else:
		fire_timer = 0.0

func _fire_projectile() -> void:
	if current_target == null or not is_instance_valid(current_target):
		return

	var proj: ProjectilePlaceholder = PROJECTILE_SCENE.instantiate() as ProjectilePlaceholder
	if proj != null:
		var spawn_pos: Vector2 = global_position + Vector2(0, -13)
		proj.global_position = spawn_pos
		proj.setup(current_target)
		if projectiles_container != null:
			projectiles_container.add_child(proj)
		elif get_parent() != null:
			get_parent().add_child(proj)

func _update_target() -> void:
	# Validate current target if exists
	if current_target != null:
		if not is_instance_valid(current_target) or not _is_enemy_valid_target(current_target):
			current_target = null
		else:
			var dist: float = global_position.distance_to(current_target.global_position)
			if dist > detection_range:
				current_target = null

	# Acquire new target if none
	if current_target == null and enemies_container != null:
		var closest_enemy: EnemyPlaceholder = null
		var closest_dist: float = detection_range + 1.0

		for child: Node in enemies_container.get_children():
			if child is EnemyPlaceholder:
				var enemy: EnemyPlaceholder = child as EnemyPlaceholder
				if _is_enemy_valid_target(enemy):
					var dist: float = global_position.distance_to(enemy.global_position)
					if dist <= detection_range and dist < closest_dist:
						closest_dist = dist
						closest_enemy = enemy

		current_target = closest_enemy

func _is_enemy_valid_target(enemy: EnemyPlaceholder) -> bool:
	return enemy != null and is_instance_valid(enemy)

func _draw() -> void:
	# Defender Structure (Godot primitives at local origin)
	# Platform pedestal top offset shadow
	_draw_ellipse_filled(Vector2(0, 4), 16.0, 9.0, Color(0.02, 0.04, 0.06, 0.5))

	# Golden Guard Shield / Base
	var base_pts: PackedVector2Array = PackedVector2Array([
		Vector2(0, -18),
		Vector2(14, -6),
		Vector2(10, 8),
		Vector2(-10, 8),
		Vector2(-14, -6)
	])
	draw_colored_polygon(base_pts, Color(0.85, 0.7, 0.2, 1.0))
	_draw_polyline_closed(base_pts, Color(1.0, 0.9, 0.5, 0.9), 1.5)

	# Defender Crystal Core
	var crystal_pts: PackedVector2Array = PackedVector2Array([
		Vector2(0, -22),
		Vector2(7, -12),
		Vector2(0, -4),
		Vector2(-7, -12)
	])
	draw_colored_polygon(crystal_pts, Color(0.2, 0.85, 0.95, 0.95))
	_draw_polyline_closed(crystal_pts, Color(0.8, 0.95, 1.0, 1.0), 1.5)
	draw_circle(Vector2(0, -13), 3.0, Color(1.0, 1.0, 1.0, 0.95))

	# Range Indicator Ring (Subtle guide)
	_draw_ellipse_stroke(Vector2.ZERO, detection_range, detection_range * 0.58, Color(0.2, 0.6, 0.8, 0.18), 1.0, 36)

	# Target Visual Indicator (Line + Reticle when target acquired)
	if current_target != null and is_instance_valid(current_target):
		var target_local_pos: Vector2 = current_target.global_position - global_position
		
		# Targeting Beam Line from defender top crystal to enemy center
		var beam_start: Vector2 = Vector2(0, -13)
		draw_line(beam_start, target_local_pos, Color(1.0, 0.3, 0.3, 0.85), 2.0, true)
		draw_line(beam_start, target_local_pos, Color(1.0, 0.8, 0.4, 0.5), 4.0, true)

		# Target Reticle on enemy
		_draw_reticle(target_local_pos)

func _draw_reticle(local_pos: Vector2) -> void:
	var reticle_color: Color = Color(1.0, 0.25, 0.25, 0.95)
	_draw_ellipse_stroke(local_pos, 16.0, 10.0, reticle_color, 1.5, 24)
	
	# Crosshair ticks
	draw_line(local_pos + Vector2(-22, 0), local_pos + Vector2(-12, 0), reticle_color, 1.5)
	draw_line(local_pos + Vector2(12, 0), local_pos + Vector2(22, 0), reticle_color, 1.5)
	draw_line(local_pos + Vector2(0, -14), local_pos + Vector2(0, -7), reticle_color, 1.5)
	draw_line(local_pos + Vector2(0, 7), local_pos + Vector2(0, 14), reticle_color, 1.5)

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 24) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)

func _draw_ellipse_stroke(pos: Vector2, rx: float, ry: float, color: Color, width: float = 1.0, segments: int = 24) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments + 1):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_polyline(pts, color, width, true)

func _draw_polyline_closed(pts: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	var closed_pts: PackedVector2Array = pts.duplicate()
	closed_pts.append(pts[0])
	draw_polyline(closed_pts, color, width, true)
