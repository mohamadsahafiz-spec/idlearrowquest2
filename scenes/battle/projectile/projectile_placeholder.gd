class_name ProjectilePlaceholder
extends Node2D

@export var speed: float = 380.0
@export var damage: float = 15.0
@export var is_critical: bool = false
@export var hit_distance: float = 12.0
@export var max_lifetime: float = 4.0

var target: EnemyPlaceholder = null
var lifetime: float = 0.0
var source_maid: DefenderPlaceholder = null

func _ready() -> void:
	pass

func setup(p_target: EnemyPlaceholder) -> void:
	target = p_target

func _process(delta: float) -> void:
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
		return

	if target == null or not is_instance_valid(target) or target.is_dead:
		queue_free()
		return

	var target_pos: Vector2 = target.global_position
	var dist: float = global_position.distance_to(target_pos)
	var move_dist: float = speed * delta

	if dist <= hit_distance or move_dist >= dist:
		global_position = target_pos
		_on_hit_target()
		queue_free()
		return

	var dir: Vector2 = (target_pos - global_position).normalized()
	global_position += dir * move_dist
	queue_redraw()

func _on_hit_target() -> void:
	if target != null and is_instance_valid(target):
		if target.has_method("take_damage_from_maid"):
			target.take_damage_from_maid(damage, is_critical, source_maid)
		elif target.has_method("take_damage"):
			if is_instance_valid(source_maid):
				source_maid.record_damage(damage, is_critical)
			var target_was_alive: bool = not target.is_dead
			target.take_damage(damage, is_critical)
			if target_was_alive and target.is_dead and is_instance_valid(source_maid):
				source_maid.record_kill()

func _draw() -> void:
	# Projectile visual: glowing energetic sphere with shadow, trail and core
	# Ground Shadow
	_draw_ellipse_filled(Vector2(0, 4), 6.0, 3.0, Color(0.02, 0.04, 0.06, 0.4))

	var aura_color: Color = Color(1.0, 0.85, 0.2, 0.55) if is_critical else Color(0.3, 0.85, 1.0, 0.45)
	var body_color: Color = Color(1.0, 0.9, 0.3, 1.0) if is_critical else Color(0.4, 0.9, 1.0, 0.95)
	var aura_radius: float = 9.0 if is_critical else 7.0
	var body_radius: float = 5.0 if is_critical else 4.0

	# Trailing motion flare
	if target != null and is_instance_valid(target):
		var dir_to_target: Vector2 = (target.global_position - global_position).normalized()
		var tail_vec: Vector2 = -dir_to_target * (10.0 if is_critical else 7.0)
		draw_line(Vector2.ZERO, tail_vec, aura_color, body_radius * 1.8)

	# Outer aura
	draw_circle(Vector2.ZERO, aura_radius, aura_color)
	# Inner projectile body
	draw_circle(Vector2.ZERO, body_radius, body_color)
	# Bright core
	draw_circle(Vector2.ZERO, body_radius * 0.5, Color(1.0, 1.0, 1.0, 1.0))

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 16) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)
