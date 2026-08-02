class_name EnemyPlaceholder
extends Node2D

signal reached_destination
signal enemy_died(coins: int, pos: Vector2)
signal hp_changed(current_hp: float, max_hp: float)

@export var stats: EnemyStats
@export var current_hp: float = 100.0
@export var death_duration: float = 0.6
@export var enemy_color: Color = Color(0.95, 0.25, 0.25, 1.0)
@export var outline_color: Color = Color(1.0, 0.85, 0.85, 0.9)
@export var radius: float = 10.0
@export var defender_target: DefenderPlaceholder = null

var max_hp: float:
	get:
		return stats.get_max_hp() if stats != null else 100.0

var speed: float:
	get:
		return stats.get_movement_speed() if stats != null else 85.0

var coin_reward: int:
	get:
		return stats.get_reward() if stats != null else 10

var attack: float:
	get:
		return stats.get_attack_damage() if stats != null else 10.0

var attack_speed: float:
	get:
		return stats.get_attack_speed() if stats != null else 1.0

var attack_cooldown: float:
	get:
		return stats.get_attack_cooldown() if stats != null else 1.0

var path_points: PackedVector2Array = PackedVector2Array()
var current_waypoint_index: int = 0
var is_moving: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0
var is_dead: bool = false
var death_timer: float = 0.0
var damage_popups: Array[Dictionary] = []
var reward_popups: Array[Dictionary] = []
var hit_sparks: Array[Dictionary] = []
var hit_flash_timer: float = 0.0

func apply_stats() -> void:
	if stats == null:
		stats = EnemyStats.new()
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	enemy_color = stats.get_tier_color()
	outline_color = stats.get_tier_outline_color()
	radius = 10.0 * stats.get_tier_radius_multiplier()

func _ready() -> void:
	apply_stats()

func take_damage(amount: float, is_critical: bool = false) -> void:
	if is_dead:
		return

	current_hp = maxf(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	hit_flash_timer = 0.14
	_add_hit_spark(is_critical)
	_add_damage_popup(amount, is_critical)

	if current_hp <= 0.0:
		_die()

	queue_redraw()

func _die() -> void:
	is_dead = true
	is_moving = false
	is_attacking = false
	death_timer = death_duration
	_add_reward_popup(coin_reward)
	enemy_died.emit(coin_reward, global_position)

func _add_hit_spark(is_critical: bool = false) -> void:
	var spark_info: Dictionary = {
		"life": 0.22 if is_critical else 0.14,
		"max_life": 0.22 if is_critical else 0.14,
		"is_critical": is_critical
	}
	hit_sparks.append(spark_info)

func _add_damage_popup(amount: float, is_critical: bool = false) -> void:
	var popup_count: int = damage_popups.size()
	var x_stagger: float = randf_range(-14.0, 14.0) + (sin(popup_count * 1.8) * 8.0)
	var y_base: float = -radius * 1.3 - (30.0 if is_critical else 22.0) - (popup_count * 6.0)
	y_base = clampf(y_base, -radius * 1.3 - 60.0, -radius * 1.3 - 20.0)

	var text_label: String = ("CRIT -" if is_critical else "-") + str(int(amount))
	var popup_info: Dictionary = {
		"text": text_label,
		"is_critical": is_critical,
		"offset": Vector2(x_stagger, y_base),
		"life": 1.15 if is_critical else 0.85,
		"max_life": 1.15 if is_critical else 0.85
	}
	damage_popups.append(popup_info)

func _add_reward_popup(coins: int) -> void:
	var popup_info: Dictionary = {
		"text": "+" + str(coins) + " Coins",
		"offset": Vector2(0.0, -radius * 1.3 - 24.0),
		"life": 0.9,
		"max_life": 0.9
	}
	reward_popups.append(popup_info)

func start_path(points: PackedVector2Array) -> void:
	path_points = points
	if path_points.size() > 0:
		position = path_points[0]
		current_waypoint_index = 1
		is_moving = true
	else:
		is_moving = false

func _process(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(0.0, hit_flash_timer - delta)

	if is_dead:
		death_timer -= delta
		_update_popups(delta)
		queue_redraw()
		if death_timer <= 0.0:
			queue_free()
		return

	_update_popups(delta)

	if is_moving and current_waypoint_index < path_points.size():
		var target_pos: Vector2 = path_points[current_waypoint_index]
		var distance_to_target: float = position.distance_to(target_pos)
		var move_distance: float = speed * delta

		if move_distance >= distance_to_target:
			position = target_pos
			current_waypoint_index += 1
			if current_waypoint_index >= path_points.size():
				is_moving = false
				is_attacking = true
				attack_timer = 0.0
				reached_destination.emit()
		else:
			var direction: Vector2 = (target_pos - position).normalized()
			position += direction * move_distance

	if is_attacking:
		_update_attacking(delta)

	queue_redraw()

func _update_attacking(delta: float) -> void:
	if not is_attacking or is_dead:
		return

	if defender_target == null or not is_instance_valid(defender_target):
		_find_defender_target()

	if defender_target != null and is_instance_valid(defender_target):
		var cd: float = attack_cooldown
		attack_timer -= delta
		if attack_timer > cd:
			attack_timer = cd
		if attack_timer <= 0.0:
			if defender_target.has_method("take_damage"):
				defender_target.take_damage(attack)
			attack_timer = cd

func _find_defender_target() -> void:
	if get_parent() != null and get_parent().get_parent() != null:
		var arena: Node = get_parent().get_parent()
		if arena.has_node("DefenderPlaceholder"):
			defender_target = arena.get_node("DefenderPlaceholder") as DefenderPlaceholder

func _update_popups(delta: float) -> void:
	# Update damage popups
	var i: int = damage_popups.size() - 1
	while i >= 0:
		var popup: Dictionary = damage_popups[i]
		var life: float = float(popup["life"]) - delta
		popup["life"] = life
		var offset: Vector2 = popup["offset"] as Vector2
		popup["offset"] = offset + Vector2(0.0, -28.0 * delta)
		if life <= 0.0:
			damage_popups.remove_at(i)
		i -= 1

	# Update reward popups
	var j: int = reward_popups.size() - 1
	while j >= 0:
		var popup: Dictionary = reward_popups[j]
		var life: float = float(popup["life"]) - delta
		popup["life"] = life
		var offset: Vector2 = popup["offset"] as Vector2
		popup["offset"] = offset + Vector2(0.0, -32.0 * delta)
		if life <= 0.0:
			reward_popups.remove_at(j)
		j -= 1

	# Update hit sparks
	var k: int = hit_sparks.size() - 1
	while k >= 0:
		var spark: Dictionary = hit_sparks[k]
		var spark_life: float = float(spark["life"]) - delta
		spark["life"] = spark_life
		if spark_life <= 0.0:
			hit_sparks.remove_at(k)
		k -= 1

func _draw() -> void:
	if is_dead:
		_draw_death_visual()
		_draw_damage_popups()
		_draw_reward_popups()
		return

	# Ground Shadow
	var shadow_pos: Vector2 = Vector2(0, 8)
	_draw_ellipse_filled(shadow_pos, radius * 1.2, radius * 0.6, Color(0.02, 0.04, 0.06, 0.5))

	# Tier Aura Rings
	if stats != null and stats.tier == EnemyStats.Tier.BOSS:
		draw_arc(Vector2.ZERO, radius * 1.6, 0, TAU, 32, Color(1.0, 0.2, 0.3, 0.8), 2.5, true)
		draw_arc(Vector2.ZERO, radius * 1.85, 0, TAU, 32, Color(1.0, 0.85, 0.2, 0.65), 1.5, true)
	elif stats != null and stats.tier == EnemyStats.Tier.ELITE:
		draw_arc(Vector2.ZERO, radius * 1.45, 0, TAU, 24, Color(0.8, 0.4, 1.0, 0.6), 1.5, true)
	elif stats != null and stats.tier == EnemyStats.Tier.STRONG:
		draw_arc(Vector2.ZERO, radius * 1.3, 0, TAU, 20, Color(1.0, 0.6, 0.2, 0.5), 1.0, true)

	# Enemy Body (Stylized primitive diamond/orb)
	var pts: PackedVector2Array = PackedVector2Array([
		Vector2(0, -radius * 1.3),
		Vector2(radius, 0),
		Vector2(0, radius * 0.9),
		Vector2(-radius, 0)
	])

	var body_col: Color = enemy_color
	if hit_flash_timer > 0.0:
		var flash_ratio: float = hit_flash_timer / 0.14
		body_col = enemy_color.lerp(Color(1.0, 1.0, 1.0, 1.0), flash_ratio * 0.7)

	draw_colored_polygon(pts, body_col)
	_draw_polyline_closed(pts, outline_color, 2.0)

	# Hit Flash Overlay Ring
	if hit_flash_timer > 0.0:
		var flash_alpha: float = clampf(hit_flash_timer / 0.14, 0.0, 1.0)
		_draw_polyline_closed(pts, Color(1.0, 1.0, 0.8, flash_alpha * 0.9), 3.0)

	# Core Glow Center
	var core_color: Color = Color(1.0, 0.9, 0.4, 0.95)
	if stats != null and stats.tier == EnemyStats.Tier.BOSS:
		core_color = Color(1.0, 0.95, 0.2, 1.0)
	elif stats != null and stats.tier == EnemyStats.Tier.ELITE:
		core_color = Color(0.4, 0.95, 1.0, 0.95)
	elif stats != null and stats.tier == EnemyStats.Tier.STRONG:
		core_color = Color(1.0, 0.95, 0.5, 0.95)

	if hit_flash_timer > 0.0:
		core_color = Color(1.0, 1.0, 0.9, 1.0)

	draw_circle(Vector2(0, -radius * 0.2), radius * 0.4, core_color)

	# Active Hit Sparks Ring
	for spark: Dictionary in hit_sparks:
		var s_life: float = float(spark["life"])
		var s_max: float = float(spark["max_life"])
		var s_alpha: float = clampf(s_life / maxf(0.001, s_max), 0.0, 1.0)
		var is_crit_spark: bool = bool(spark["is_critical"])
		var spark_rad: float = radius * (1.6 - s_alpha * 0.5) if is_crit_spark else radius * (1.3 - s_alpha * 0.3)
		var spark_col: Color = Color(1.0, 0.88, 0.2, s_alpha * 0.95) if is_crit_spark else Color(1.0, 0.45, 0.35, s_alpha * 0.8)
		draw_arc(Vector2(0, -radius * 0.2), spark_rad, 0, TAU, 20, spark_col, 2.0 if is_crit_spark else 1.5, true)

	# Enemy HP Bar
	_draw_hp_bar()

	# Floating Damage Popups
	_draw_damage_popups()

	# Floating Reward Popups
	_draw_reward_popups()

func _draw_death_visual() -> void:
	var fade_alpha: float = clampf(death_timer / maxf(0.001, death_duration), 0.0, 1.0)

	# Ground Shadow Fading
	var shadow_pos: Vector2 = Vector2(0, 8)
	_draw_ellipse_filled(shadow_pos, radius * 1.2 * fade_alpha, radius * 0.6 * fade_alpha, Color(0.02, 0.04, 0.06, 0.5 * fade_alpha))

	# Dissolving Burst Ring
	var burst_radius: float = radius * (1.0 + (1.0 - fade_alpha) * 1.8)
	draw_arc(Vector2.ZERO, burst_radius, 0, TAU, 24, Color(1.0, 0.6, 0.2, fade_alpha * 0.8), 2.0, true)

	# Fading Core Spark
	var spark_radius: float = radius * 0.8 * fade_alpha
	draw_circle(Vector2(0, -radius * 0.2), spark_radius, Color(1.0, 0.9, 0.4, fade_alpha * 0.95))

	# Dissolving diamond fragments
	var expand: float = (1.0 - fade_alpha) * 12.0
	var top_pt: Vector2 = Vector2(0, -radius * 1.3 - expand)
	var right_pt: Vector2 = Vector2(radius + expand, 0)
	var bottom_pt: Vector2 = Vector2(0, radius * 0.9 + expand)
	var left_pt: Vector2 = Vector2(-radius - expand, 0)

	draw_line(Vector2(0, -radius * 0.2), top_pt, Color(0.95, 0.35, 0.25, fade_alpha * 0.7), 2.0)
	draw_line(Vector2(0, -radius * 0.2), right_pt, Color(0.95, 0.35, 0.25, fade_alpha * 0.7), 2.0)
	draw_line(Vector2(0, -radius * 0.2), bottom_pt, Color(0.95, 0.35, 0.25, fade_alpha * 0.7), 2.0)
	draw_line(Vector2(0, -radius * 0.2), left_pt, Color(0.95, 0.35, 0.25, fade_alpha * 0.7), 2.0)

func _draw_hp_bar() -> void:
	var bar_width: float = 32.0 * (stats.get_tier_radius_multiplier() if stats != null else 1.0)
	var bar_height: float = 4.0
	var bar_pos: Vector2 = Vector2(-bar_width * 0.5, -radius * 1.3 - 12.0)

	# Optional Tier Label above HP bar
	if stats != null and stats.tier != EnemyStats.Tier.NORMAL:
		var font: Font = ThemeDB.fallback_font
		if font != null:
			var is_boss: bool = (stats.tier == EnemyStats.Tier.BOSS)
			var font_size: int = 11 if is_boss else 9
			var tier_label: String = stats.get_tier_name().to_upper()
			var label_pos: Vector2 = bar_pos + Vector2(bar_width * 0.5, -4.0 if is_boss else -3.0)
			var text_color: Color = Color(1.0, 0.85, 0.25, 1.0) if is_boss else enemy_color
			draw_string(font, label_pos + Vector2(1, 1), tier_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.0, 0.0, 0.0, 0.9))
			draw_string(font, label_pos, tier_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

	# Background rect
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.08, 0.1, 0.14, 0.85))

	# Fill rect
	var hp_pct: float = clampf(current_hp / maxf(1.0, max_hp), 0.0, 1.0)
	if hp_pct > 0.0:
		var fill_width: float = bar_width * hp_pct
		var fill_color: Color = Color(0.2, 0.85, 0.4, 0.9)
		if hp_pct <= 0.25:
			fill_color = Color(0.95, 0.25, 0.25, 0.9)
		elif hp_pct <= 0.5:
			fill_color = Color(0.95, 0.75, 0.2, 0.9)
		draw_rect(Rect2(bar_pos, Vector2(fill_width, bar_height)), fill_color)

	# Border outline
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.4, 0.5, 0.65, 0.8), false, 1.0)

func _draw_damage_popups() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	for popup: Dictionary in damage_popups:
		var life: float = float(popup["life"])
		var max_life: float = float(popup["max_life"])
		var alpha: float = clampf(life / max_life, 0.0, 1.0)
		var text_pos: Vector2 = popup["offset"] as Vector2
		var text_str: String = popup["text"] as String
		var is_crit: bool = popup.get("is_critical", false) as bool

		var progress: float = 1.0 - (life / max_life)
		var pop_bounce: float = sin(clampf(progress * PI * 2.0, 0.0, PI)) * (6.0 if is_crit else 3.0)
		var render_pos: Vector2 = text_pos + Vector2(0.0, -pop_bounce)

		if is_crit:
			var font_size: int = 15
			# CRIT Golden Flare Arc
			var flare_alpha: float = alpha * clampf(1.0 - progress * 2.5, 0.0, 1.0)
			if flare_alpha > 0.0:
				draw_arc(render_pos + Vector2(0, -4), 16.0 * (1.0 + progress * 0.5), 0, TAU, 16, Color(1.0, 0.85, 0.2, flare_alpha * 0.7), 2.0, true)

			# Drop shadow / Thick black outline
			draw_string(font, render_pos + Vector2(1.5, 1.5), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.0, 0.0, 0.0, alpha * 0.95))
			draw_string(font, render_pos + Vector2(-1.0, -1.0), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.0, 0.0, 0.0, alpha * 0.85))
			# Main text in prominent golden amber
			draw_string(font, render_pos, text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(1.0, 0.9, 0.25, alpha))
		else:
			var font_size: int = 12
			# Drop shadow / outline
			draw_string(font, render_pos + Vector2(1, 1), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.0, 0.0, 0.0, alpha * 0.9))
			# Main text in clean bright white-pink
			draw_string(font, render_pos, text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(1.0, 0.95, 0.95, alpha))

func _draw_reward_popups() -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return

	for popup: Dictionary in reward_popups:
		var life: float = float(popup["life"])
		var max_life: float = float(popup["max_life"])
		var alpha: float = clampf(life / max_life, 0.0, 1.0)
		var text_pos: Vector2 = popup["offset"] as Vector2
		var text_str: String = popup["text"] as String

		# Drop shadow
		draw_string(font, text_pos + Vector2(1, 1), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.0, 0.0, 0.0, alpha * 0.85))
		# Main text in bright golden amber
		draw_string(font, text_pos, text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(1.0, 0.85, 0.2, alpha))

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
