class_name LiriaVisual
extends Node2D

var idle_timer: float = 0.0
var attack_anim_timer: float = 0.0
var aim_angle: float = 0.0
var is_attacking: bool = false
var is_defeated: bool = false
var hit_flash: float = 0.0

func _process(delta: float) -> void:
	idle_timer += delta * 3.0
	if attack_anim_timer > 0.0:
		attack_anim_timer = maxf(0.0, attack_anim_timer - delta * 4.0)
	if hit_flash > 0.0:
		hit_flash = maxf(0.0, hit_flash - delta * 6.0)
	queue_redraw()

func trigger_attack(target_pos: Vector2) -> void:
	attack_anim_timer = 1.0
	aim_angle = (target_pos - global_position).angle()

func trigger_hit() -> void:
	hit_flash = 1.0

func get_bow_launch_position() -> Vector2:
	var base_launch: Vector2 = global_position + Vector2(12.0, -16.0)
	var dir: Vector2 = Vector2(cos(aim_angle), sin(aim_angle))
	return base_launch + dir * 10.0

func _draw() -> void:
	var bob: float = sin(idle_timer) * 1.5 if not is_defeated else 0.0
	var recoil: float = sin(attack_anim_timer * PI) * 4.0

	if is_defeated:
		# Defeat pose (tilted back)
		draw_set_transform(Vector2(0, 8), -0.6, Vector2(1, 1))

	var head_pos: Vector2 = Vector2(0, -28 + bob)
	var body_pos: Vector2 = Vector2(0, -12 + bob)

	# 1. Shadow
	_draw_ellipse_filled(Vector2(0, 2), 14.0, 7.0, Color(0.05, 0.08, 0.12, 0.45))

	# 2. Quiver on Back (Left/Rear)
	var quiver_pts: PackedVector2Array = PackedVector2Array([
		body_pos + Vector2(-12, -8),
		body_pos + Vector2(-8, -20),
		body_pos + Vector2(-4, -18),
		body_pos + Vector2(-8, -6)
	])
	draw_colored_polygon(quiver_pts, Color(0.35, 0.22, 0.12, 1.0)) # Leather
	# Arrows in quiver
	draw_line(body_pos + Vector2(-8, -20), body_pos + Vector2(-10, -28), Color(0.8, 0.75, 0.7, 1.0), 2.0)
	draw_line(body_pos + Vector2(-6, -19), body_pos + Vector2(-7, -27), Color(0.8, 0.75, 0.7, 1.0), 2.0)

	# 3. Legs & Maid Shoes
	# White stockings
	draw_line(body_pos + Vector2(-4, 2), body_pos + Vector2(-4, 10), Color(0.95, 0.95, 0.98, 1.0), 4.0)
	draw_line(body_pos + Vector2(4, 2), body_pos + Vector2(4, 10), Color(0.95, 0.95, 0.98, 1.0), 4.0)
	# Black shoes
	draw_circle(body_pos + Vector2(-4, 10), 3.0, Color(0.1, 0.1, 0.12, 1.0))
	draw_circle(body_pos + Vector2(4, 10), 3.0, Color(0.1, 0.1, 0.12, 1.0))

	# 4. Black Maid Dress & White Apron
	var dress_pts: PackedVector2Array = PackedVector2Array([
		body_pos + Vector2(-6, -12),
		body_pos + Vector2(6, -12),
		body_pos + Vector2(10, 2),
		body_pos + Vector2(-10, 2)
	])
	draw_colored_polygon(dress_pts, Color(0.12, 0.12, 0.15, 1.0)) # Black dress

	var apron_pts: PackedVector2Array = PackedVector2Array([
		body_pos + Vector2(-4, -10),
		body_pos + Vector2(4, -10),
		body_pos + Vector2(7, 2),
		body_pos + Vector2(-7, 2)
	])
	draw_colored_polygon(apron_pts, Color(0.96, 0.96, 0.98, 1.0)) # White apron frill
	# Apron frill border
	draw_polyline(apron_pts, Color(0.88, 0.88, 0.92, 1.0), 1.0, true)

	# 5. Silver/White Chibi Hair (Back layer)
	draw_circle(head_pos + Vector2(-10, 2), 7.0, Color(0.88, 0.9, 0.95, 1.0))
	draw_circle(head_pos + Vector2(10, 2), 7.0, Color(0.88, 0.9, 0.95, 1.0))

	# 6. Face (Cute rounded chibi)
	draw_circle(head_pos, 11.0, Color(1.0, 0.92, 0.88, 1.0))

	# Soft Violet Eyes
	_draw_ellipse_filled(head_pos + Vector2(-4, -1), 2.2, 3.5, Color(0.4, 0.35, 0.65, 1.0))
	_draw_ellipse_filled(head_pos + Vector2(4, -1), 2.2, 3.5, Color(0.4, 0.35, 0.65, 1.0))
	# Eye highlights
	draw_circle(head_pos + Vector2(-4.5, -2), 1.0, Color.WHITE)
	draw_circle(head_pos + Vector2(3.5, -2), 1.0, Color.WHITE)
	# Blush
	_draw_ellipse_filled(head_pos + Vector2(-6, 3), 2.5, 1.2, Color(1.0, 0.6, 0.6, 0.4))
	_draw_ellipse_filled(head_pos + Vector2(6, 3), 2.5, 1.2, Color(1.0, 0.6, 0.6, 0.4))

	# 7. Silver Hair (Front Bangs & Bob)
	var hair_color: Color = Color(0.92, 0.94, 0.98, 1.0)
	draw_circle(head_pos + Vector2(0, -6), 11.5, hair_color)
	# Bangs
	draw_circle(head_pos + Vector2(-6, -4), 5.5, hair_color)
	draw_circle(head_pos + Vector2(0, -5), 5.0, hair_color)
	draw_circle(head_pos + Vector2(6, -4), 5.5, hair_color)

	# 8. Maid Headband & Black Ribbons
	var headband_pts: PackedVector2Array = PackedVector2Array([
		head_pos + Vector2(-11, -8),
		head_pos + Vector2(0, -14),
		head_pos + Vector2(11, -8),
		head_pos + Vector2(0, -11)
	])
	draw_colored_polygon(headband_pts, Color(0.98, 0.98, 1.0, 1.0)) # White frilled ruffle
	draw_circle(head_pos + Vector2(-11, -7), 3.0, Color(0.15, 0.15, 0.18, 1.0)) # Black bow L
	draw_circle(head_pos + Vector2(11, -7), 3.0, Color(0.15, 0.15, 0.18, 1.0)) # Black bow R

	# 9. Starter Bow (Right hand / aiming direction)
	var bow_center: Vector2 = body_pos + Vector2(8 - recoil, -4)
	var bow_angle: float = aim_angle
	var p_top: Vector2 = bow_center + Vector2(cos(bow_angle - 1.0), sin(bow_angle - 1.0)) * 18.0
	var p_bot: Vector2 = bow_center + Vector2(cos(bow_angle + 1.0), sin(bow_angle + 1.0)) * 18.0

	# Golden-brown wooden bow arc
	draw_arc(bow_center, 18.0, bow_angle - 1.0, bow_angle + 1.0, 16, Color(0.65, 0.45, 0.22, 1.0), 3.0, true)
	draw_arc(bow_center, 18.0, bow_angle - 1.0, bow_angle + 1.0, 16, Color(0.95, 0.8, 0.4, 1.0), 1.5, true)

	# Bow string
	var string_back: Vector2 = bow_center - Vector2(cos(bow_angle), sin(bow_angle)) * (2.0 + recoil * 1.5)
	draw_line(p_top, string_back, Color(0.95, 0.95, 1.0, 0.85), 1.2)
	draw_line(p_bot, string_back, Color(0.95, 0.95, 1.0, 0.85), 1.2)

	# Hit flash overlay
	if hit_flash > 0.0:
		draw_circle(head_pos, 14.0, Color(1.0, 0.3, 0.3, hit_flash * 0.6))

func _draw_ellipse_filled(pos: Vector2, rx: float, ry: float, color: Color, segments: int = 16) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in range(segments):
		var a: float = float(i) * TAU / float(segments)
		pts.append(pos + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, color)
