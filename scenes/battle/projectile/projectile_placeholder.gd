class_name ProjectilePlaceholder
extends Node2D

@export var speed: float = 380.0
@export var damage: float = 15.0
@export var is_critical: bool = false
@export var hit_distance: float = 12.0
@export var max_lifetime: float = 4.0

var target: EnemyPlaceholder = null
var lifetime: float = 0.0

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
		if target.has_method("take_damage"):
			target.take_damage(damage, is_critical)

func _draw() -> void:
	# Projectile visual: glowing energetic sphere with shadow and core
	# Ground Shadow
	_draw_ellipse_filled(Vector2(0, 4), 6.0, 3.0, Color(0.02, 0.04, 0.06, 0.4))
	
	# Outer aura
	draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.8, 0.3, 0.4))
	# Inner projectile body
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.9, 0.4, 0.95))
	# Bright core
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 1.0, 1.0, 1.0))

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 16) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)
