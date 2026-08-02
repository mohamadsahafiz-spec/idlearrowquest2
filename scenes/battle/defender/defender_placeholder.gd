class_name DefenderPlaceholder
extends Node2D

signal hp_changed(current_hp: float, max_hp: float)
signal defender_died()

@export var stats: DefenderStats
@export var current_hp: float = 100.0
@export var show_debug_visuals: bool = false
@export var enemies_container: Node2D
@export var projectiles_container: Node2D
@export var custom_visual_node: Node2D = null

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/battle/projectile/projectile_placeholder.tscn")

var current_target: EnemyPlaceholder = null
var fire_timer: float = 0.0
var damage_popups: Array[Dictionary] = []
var hit_flash_timer: float = 0.0
var is_overdrive_active: bool = false

var max_hp: float:
	get:
		return stats.get_max_hp() if stats != null else 100.0

var attack_range: float:
	get:
		return stats.get_attack_range() if stats != null else 240.0

var detection_range: float:
	get:
		return attack_range

var fire_cooldown: float:
	get:
		return stats.get_fire_cooldown() if stats != null else 0.8

var damage: float:
	get:
		return stats.get_attack_damage() if stats != null else 15.0

var base_max_hp: float = 100.0
var base_attack: float = 15.0
var base_attack_speed: float = 1.25
var base_critical_chance: float = 0.05

var liria_visual: LiriaVisual = null

func _ready() -> void:
	if stats == null:
		stats = DefenderStats.new()
	base_max_hp = stats.max_hp
	base_attack = stats.attack
	base_attack_speed = stats.attack_speed
	base_critical_chance = stats.critical_chance
	current_hp = max_hp

	if custom_visual_node == null:
		liria_visual = LiriaVisual.new()
		liria_visual.name = "LiriaVisual"
		add_child(liria_visual)
		custom_visual_node = liria_visual

	hp_changed.emit(current_hp, max_hp)

func restore_base_stats() -> void:
	if stats != null:
		stats.max_hp = base_max_hp
		stats.attack = base_attack
		stats.attack_speed = base_attack_speed
		stats.critical_chance = base_critical_chance
	current_hp = base_max_hp
	if liria_visual != null:
		liria_visual.is_defeated = false
	hp_changed.emit(current_hp, base_max_hp)
	queue_redraw()

func take_damage(amount: float) -> void:
	if current_hp <= 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	hit_flash_timer = 0.15
	if liria_visual != null:
		liria_visual.trigger_hit()
		if current_hp <= 0.0:
			liria_visual.is_defeated = true
	_add_damage_popup(amount)
	queue_redraw()
	if current_hp <= 0.0:
		defender_died.emit()

func _add_damage_popup(amount: float) -> void:
	var popup_count: int = damage_popups.size()
	var x_stagger: float = randf_range(-12.0, 12.0) + (cos(popup_count * 2.1) * 6.0)
	var y_base: float = -32.0 - (popup_count * 5.0)
	y_base = clampf(y_base, -60.0, -26.0)

	var popup_info: Dictionary = {
		"text": "-" + str(int(amount)),
		"offset": Vector2(x_stagger, y_base),
		"life": 0.9,
		"max_life": 0.9
	}
	damage_popups.append(popup_info)

func _process(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
	_update_popups(delta)
	_update_target()
	_update_firing(delta)
	queue_redraw()

func _update_popups(delta: float) -> void:
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

func _update_firing(delta: float) -> void:
	if current_target != null and is_instance_valid(current_target) and _is_enemy_in_range(current_target):
		var cd: float = fire_cooldown
		fire_timer -= delta
		if fire_timer > cd:
			fire_timer = cd
		if fire_timer <= 0.0:
			_fire_projectile()
			fire_timer = cd
	else:
		fire_timer = 0.0

func _fire_projectile() -> void:
	if current_target == null or not is_instance_valid(current_target) or not _is_enemy_in_range(current_target):
		return

	if liria_visual != null:
		liria_visual.trigger_attack(current_target.global_position)

	var proj: ProjectilePlaceholder = PROJECTILE_SCENE.instantiate() as ProjectilePlaceholder
	if proj != null:
		var spawn_pos: Vector2 = liria_visual.get_bow_launch_position() if liria_visual != null else global_position + Vector2(0, -13)
		proj.global_position = spawn_pos
		proj.setup(current_target)
		var hit_info: Dictionary = stats.calculate_hit_damage() if stats != null else {"damage": damage, "is_critical": false}
		proj.damage = float(hit_info["damage"])
		proj.is_critical = bool(hit_info["is_critical"])
		if projectiles_container != null:
			projectiles_container.add_child(proj)
		elif get_parent() != null:
			get_parent().add_child(proj)

func _update_target() -> void:
	# Validate current target if exists
	if current_target != null:
		if not is_instance_valid(current_target) or not _is_enemy_valid_target(current_target) or not _is_enemy_in_range(current_target):
			current_target = null

	# Acquire new target if none
	if current_target == null and enemies_container != null:
		var closest_enemy: EnemyPlaceholder = null
		var closest_dist: float = attack_range + 1.0

		for child: Node in enemies_container.get_children():
			if child is EnemyPlaceholder:
				var enemy: EnemyPlaceholder = child as EnemyPlaceholder
				if _is_enemy_valid_target(enemy) and _is_enemy_in_range(enemy):
					var dist: float = global_position.distance_to(enemy.global_position)
					if dist < closest_dist:
						closest_dist = dist
						closest_enemy = enemy

		current_target = closest_enemy

func _is_enemy_valid_target(enemy: EnemyPlaceholder) -> bool:
	return enemy != null and is_instance_valid(enemy) and not enemy.is_dead

func _is_enemy_in_range(enemy: EnemyPlaceholder) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	return global_position.distance_to(enemy.global_position) <= attack_range

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

	# Hit Flash Pulse Ring
	if hit_flash_timer > 0.0:
		var flash_alpha: float = clampf(hit_flash_timer / 0.15, 0.0, 1.0)
		draw_arc(Vector2(0, -6), 22.0, 0, TAU, 24, Color(1.0, 0.25, 0.25, flash_alpha * 0.8), 2.5, true)
		draw_circle(Vector2(0, -13), 6.0, Color(1.0, 0.4, 0.3, flash_alpha * 0.7))

	# Overdrive Energized Aura / Pulse
	if is_overdrive_active:
		var pulse: float = (sin(Time.get_ticks_msec() * 0.012) + 1.0) * 0.5
		var aura_col: Color = Color(0.9, 0.25, 1.0, 0.65 + pulse * 0.3)
		draw_arc(Vector2(0, -6), 28.0 + pulse * 4.0, 0, TAU, 32, aura_col, 3.0, true)
		draw_arc(Vector2(0, -6), 20.0 - pulse * 2.0, 0, TAU, 24, Color(0.4, 0.9, 1.0, 0.75), 2.0, true)
		for k: int in range(4):
			var ang: float = float(k) * (PI * 0.5) + Time.get_ticks_msec() * 0.008
			var p1: Vector2 = Vector2(cos(ang), sin(ang)) * 10.0
			var p2: Vector2 = Vector2(cos(ang + 0.4), sin(ang + 0.4)) * 18.0
			draw_line(Vector2(0, -13) + p1, Vector2(0, -13) + p2, Color(0.95, 0.6, 1.0, 0.9), 2.0)

	# Defender HP Bar
	_draw_hp_bar()

	# Floating Damage Popups
	_draw_damage_popups()

	# Debug Visuals (Range Ring + Targeting Beam + Reticle)
	if show_debug_visuals:
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

func _draw_hp_bar() -> void:
	var bar_width: float = 36.0
	var bar_height: float = 4.0
	var bar_pos: Vector2 = Vector2(-bar_width * 0.5, 12.0)

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

		var progress: float = 1.0 - (life / max_life)
		var pop_bounce: float = sin(clampf(progress * PI, 0.0, PI)) * 3.0
		var render_pos: Vector2 = text_pos + Vector2(0.0, -pop_bounce)

		# Thick dark drop shadow / outline
		draw_string(font, render_pos + Vector2(1.5, 1.5), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.1, 0.0, 0.0, alpha * 0.95))
		draw_string(font, render_pos + Vector2(-1.0, -1.0), text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.1, 0.0, 0.0, alpha * 0.85))
		# Main text in distinct vivid crimson-orange
		draw_string(font, render_pos, text_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(1.0, 0.32, 0.25, alpha))

