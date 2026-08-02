class_name EnemyPlaceholder
extends Node2D

signal reached_destination
signal enemy_died(coins: int, pos: Vector2)

@export var stats: EnemyStats
@export var current_hp: float = 100.0
@export var death_duration: float = 0.6
@export var enemy_color: Color = Color(0.95, 0.25, 0.25, 1.0)
@export var outline_color: Color = Color(1.0, 0.85, 0.85, 0.9)
@export var radius: float = 10.0

var max_hp: float:
	get:
		return stats.max_hp if stats != null else 100.0

var speed: float:
	get:
		return stats.movement_speed if stats != null else 85.0

var coin_reward: int:
	get:
		return stats.reward if stats != null else 10

var path_points: PackedVector2Array = PackedVector2Array()
var current_waypoint_index: int = 0
var is_moving: bool = false
var is_dead: bool = false
var death_timer: float = 0.0
var damage_popups: Array[Dictionary] = []
var reward_popups: Array[Dictionary] = []

func _ready() -> void:
	if stats == null:
		stats = EnemyStats.new()
	current_hp = max_hp

func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_hp = maxf(0.0, current_hp - amount)
	_add_damage_popup(amount)

	if current_hp <= 0.0:
		_die()

	queue_redraw()

func _die() -> void:
	is_dead = true
	is_moving = false
	death_timer = death_duration
	_add_reward_popup(coin_reward)
	enemy_died.emit(coin_reward, global_position)

func _add_damage_popup(amount: float) -> void:
	var popup_info: Dictionary = {
		"text": "-" + str(int(amount)),
		"offset": Vector2(randf_range(-6.0, 6.0), -radius * 1.3 - 22.0),
		"life": 0.8,
		"max_life": 0.8
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
				reached_destination.emit()
		else:
			var direction: Vector2 = (target_pos - position).normalized()
			position += direction * move_distance

	queue_redraw()

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

func _draw() -> void:
	if is_dead:
		_draw_death_visual()
		_draw_damage_popups()
		_draw_reward_popups()
		return

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
	var bar_width: float = 32.0
	var bar_height: float = 4.0
	var bar_pos: Vector2 = Vector2(-bar_width * 0.5, -radius * 1.3 - 12.0)

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

		# Drop shadow
		draw_string(font, text_pos + Vector2(1, 1), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.0, 0.0, 0.0, alpha * 0.8))
		# Main text
		draw_string(font, text_pos, text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(1.0, 0.35, 0.35, alpha))

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
