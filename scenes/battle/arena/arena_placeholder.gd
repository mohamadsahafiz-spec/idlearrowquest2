class_name ArenaPlaceholder
extends Node2D

signal enemy_killed(total_kills: int)
signal gold_earned(coins: int)

@export var respawn_delay: float = 1.0
@export var test_spawn_boss: bool = false
@export var debug_force_loot_drop: bool = false:
	set(val):
		debug_force_loot_drop = val
		if equipment_system != null:
			equipment_system.debug_force_loot_drop = val
@export var debug_force_rarity: EquipmentItem.Rarity = EquipmentItem.Rarity.COMMON:
	set(val):
		debug_force_rarity = val
		if equipment_system != null:
			equipment_system.debug_force_rarity = val
@export var show_debug_visuals: bool = false:
	set(val):
		show_debug_visuals = val
		_apply_debug_settings()

@onready var background: ArenaBackground = $Background
@onready var rings: ArenaRings = $Rings
@onready var enemy_path: EnemyPath = $EnemyPath
@onready var central_platform: CentralPlatform = $CentralPlatform
@onready var framing: ArenaFraming = $Framing
@onready var defender: DefenderPlaceholder = $DefenderPlaceholder
@onready var enemies_container: Node2D = $Enemies
@onready var projectiles_container: Node2D = $Projectiles

const ENEMY_SCENE: PackedScene = preload("res://scenes/battle/enemy/enemy_placeholder.tscn")
const DEFENDER_SCENE: PackedScene = preload("res://scenes/battle/defender/defender_placeholder.tscn")

var kill_count: int = 0
var equipment_system: EquipmentSystem = null
var skill_system: SkillSystem = null
var world_presentation: WorldPresentation = null
var active_maids: Array[DefenderPlaceholder] = []
var maid_system: MaidSystem = null:
	set(val):
		maid_system = val
		if maid_system != null:
			if not maid_system.party_changed.is_connected(_on_party_changed):
				maid_system.party_changed.connect(_on_party_changed)
			rebuild_party_combat_nodes()
var respawn_timer: float = 0.0
var pending_respawn: bool = false
var current_enemy: EnemyPlaceholder = null
var stage_system: StageSystem = null:
	set(val):
		stage_system = val
		if stage_system != null:
			if not stage_system.spawn_allowed_changed.is_connected(_on_spawn_allowed_changed):
				stage_system.spawn_allowed_changed.connect(_on_spawn_allowed_changed)
			if not stage_system.spawn_boss_requested.is_connected(_on_spawn_boss_requested):
				stage_system.spawn_boss_requested.connect(_on_spawn_boss_requested)
			if not stage_system.stage_updated.is_connected(_on_stage_updated):
				stage_system.stage_updated.connect(_on_stage_updated)

static func get_formation_offset(slot_index: int, party_size: int) -> Vector2:
	match party_size:
		1:
			return Vector2.ZERO
		2:
			var offsets: Array[Vector2] = [Vector2(-24, 0), Vector2(24, 0)]
			return offsets[slot_index] if slot_index < 2 else Vector2.ZERO
		3:
			var offsets: Array[Vector2] = [Vector2(0, 10), Vector2(-30, -15), Vector2(30, -15)]
			return offsets[slot_index] if slot_index < 3 else Vector2.ZERO
		4:
			var offsets: Array[Vector2] = [Vector2(-22, 12), Vector2(22, 12), Vector2(-32, -18), Vector2(32, -18)]
			return offsets[slot_index] if slot_index < 4 else Vector2.ZERO
		5:
			var offsets: Array[Vector2] = [Vector2(0, 16), Vector2(-30, 0), Vector2(30, 0), Vector2(-36, -22), Vector2(36, -22)]
			return offsets[slot_index] if slot_index < 5 else Vector2.ZERO
		6:
			var offsets: Array[Vector2] = [Vector2(-18, 18), Vector2(18, 18), Vector2(-36, -2), Vector2(36, -2), Vector2(-22, -24), Vector2(22, -24)]
			return offsets[slot_index] if slot_index < 6 else Vector2.ZERO
		_:
			return Vector2.ZERO

func _ready() -> void:
	world_presentation = WorldPresentation.new()
	world_presentation.name = "WorldPresentation"
	add_child(world_presentation)

	if defender != null:
		defender.enemies_container = enemies_container
		defender.projectiles_container = projectiles_container
		if not defender.defender_died.is_connected(_on_defender_died):
			defender.defender_died.connect(_on_defender_died)
		active_maids.append(defender)

	_apply_debug_settings()
	rebuild_party_combat_nodes()
	call_deferred("_initial_spawn")

func _on_party_changed(_slots: Array) -> void:
	rebuild_party_combat_nodes()

func rebuild_party_combat_nodes() -> void:
	var party: Array[String] = ["001", "", "", "", "", ""]
	if maid_system != null:
		party = maid_system.get_party()

	var active_ids: Array[String] = []
	for m_id: String in party:
		if not m_id.is_empty() and (maid_system == null or maid_system.is_unlocked(m_id)):
			if not active_ids.has(m_id):
				active_ids.append(m_id)

	if active_ids.is_empty():
		active_ids.append("001")

	for i in range(active_maids.size() - 1, -1, -1):
		var m: DefenderPlaceholder = active_maids[i]
		if m != defender and is_instance_valid(m):
			m.queue_free()
	active_maids.clear()

	var base_pos: Vector2 = Vector2(270, 454)

	for slot_idx in range(active_ids.size()):
		var m_id: String = active_ids[slot_idx]
		var offset: Vector2 = get_formation_offset(slot_idx, active_ids.size())
		var target_pos: Vector2 = base_pos + offset

		var maid_node: DefenderPlaceholder = null
		if slot_idx == 0:
			maid_node = defender
			maid_node.position = target_pos
		else:
			maid_node = DEFENDER_SCENE.instantiate() as DefenderPlaceholder
			maid_node.position = target_pos
			maid_node.stats = DefenderStats.new()
			maid_node.enemies_container = enemies_container
			maid_node.projectiles_container = projectiles_container
			add_child(maid_node)

		maid_node.setup_maid(m_id)
		if not maid_node.defender_died.is_connected(_on_defender_died):
			maid_node.defender_died.connect(_on_defender_died)

		active_maids.append(maid_node)

	_apply_debug_settings()

func get_alive_defender(from_pos: Vector2 = Vector2.ZERO) -> DefenderPlaceholder:
	var closest: DefenderPlaceholder = null
	var min_dist: float = 999999.0
	for m: DefenderPlaceholder in active_maids:
		if is_instance_valid(m) and m.current_hp > 0.0 and not m.is_defeated:
			var d: float = from_pos.distance_to(m.global_position)
			if d < min_dist:
				min_dist = d
				closest = m
	return closest

func is_party_defeated() -> bool:
	if active_maids.is_empty():
		return true
	for m: DefenderPlaceholder in active_maids:
		if is_instance_valid(m) and m.current_hp > 0.0 and not m.is_defeated:
			return false
	return true

func apply_progression_to_maids(prog_sys: ProgressionSystem, equip_sys: EquipmentSystem, is_overdrive: bool = false) -> void:
	for m: DefenderPlaceholder in active_maids:
		if is_instance_valid(m) and prog_sys != null:
			prog_sys.apply_to_defender(m, equip_sys, is_overdrive)

func _on_stage_updated(stage_num: int, _wave: int, _total_w: int, _k: int, _req: int) -> void:
	if world_presentation != null:
		var w_id: int = stage_system.current_world if stage_system != null else 1
		world_presentation.update_stage(stage_num, w_id)

func _on_defender_died() -> void:
	if is_party_defeated():
		pending_respawn = false
		if stage_system != null:
			stage_system.trigger_defeat()

func reset_arena() -> void:
	pending_respawn = false
	respawn_timer = 0.0
	kill_count = 0
	current_enemy = null
	if enemies_container != null:
		for child: Node in enemies_container.get_children():
			child.queue_free()
	if projectiles_container != null:
		for child: Node in projectiles_container.get_children():
			child.queue_free()
	for m: DefenderPlaceholder in active_maids:
		if is_instance_valid(m):
			m.restore_base_stats()

func _initial_spawn() -> void:
	spawn_enemy()

func _on_spawn_allowed_changed(allowed: bool) -> void:
	if allowed:
		if current_enemy == null or not is_instance_valid(current_enemy) or current_enemy.is_dead:
			spawn_enemy()

func _on_spawn_boss_requested() -> void:
	spawn_boss()

func _apply_debug_settings() -> void:
	if enemy_path != null:
		enemy_path.draw_path_guide = show_debug_visuals
		enemy_path.queue_redraw()
	if defender != null:
		defender.show_debug_visuals = show_debug_visuals
		defender.queue_redraw()

func _process(delta: float) -> void:
	if pending_respawn:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			pending_respawn = false
			spawn_enemy()

func get_random_enemy_tier() -> EnemyStats.Tier:
	var roll: float = randf_range(0.0, 100.0)
	if roll < 70.0:
		return EnemyStats.Tier.NORMAL
	elif roll < 95.0:
		return EnemyStats.Tier.STRONG
	else:
		return EnemyStats.Tier.ELITE

func spawn_boss() -> void:
	if enemy_path == null or enemies_container == null:
		return

	if current_enemy != null and is_instance_valid(current_enemy) and not current_enemy.is_dead:
		if current_enemy.stats != null and current_enemy.stats.tier == EnemyStats.Tier.BOSS:
			return
		current_enemy.queue_free()

	_spawn_enemy_with_tier(EnemyStats.Tier.BOSS)

func spawn_enemy() -> void:
	if test_spawn_boss:
		spawn_boss()
		return

	if enemy_path == null or enemies_container == null:
		return

	if current_enemy != null and is_instance_valid(current_enemy) and not current_enemy.is_dead:
		return

	if stage_system != null:
		if not stage_system.can_spawn_enemy():
			return
		var tier: EnemyStats.Tier = get_random_enemy_tier()
		_spawn_enemy_with_tier(tier)
		stage_system.notify_enemy_spawned()
	else:
		var tier: EnemyStats.Tier = get_random_enemy_tier()
		_spawn_enemy_with_tier(tier)

func _spawn_enemy_with_tier(tier: EnemyStats.Tier) -> void:
	var enemy_instance: EnemyPlaceholder = ENEMY_SCENE.instantiate() as EnemyPlaceholder
	if enemy_instance != null:
		var world_id: int = stage_system.current_world if stage_system != null else 1
		var stage_num: int = stage_system.current_stage if stage_system != null else 1
		enemy_instance.stats = EnemyStats.create_for_tier(tier, stage_num, world_id)
		if world_presentation != null:
			enemy_instance.stats.enemy_name = world_presentation.get_enemy_name_for_stage(stage_num, tier)
		enemy_instance.apply_stats()
		enemy_instance.defender_target = defender
		enemies_container.add_child(enemy_instance)
		current_enemy = enemy_instance
		enemy_instance.enemy_died.connect(_on_enemy_died.bind(tier))
		var points: PackedVector2Array = enemy_path.get_points()
		enemy_instance.start_path(points)

		if skill_system != null:
			skill_system.on_enemy_spawned(enemy_instance)

		if tier == EnemyStats.Tier.BOSS and stage_system != null:
			stage_system.register_boss(enemy_instance)

func _on_enemy_died(_coins: int, _pos: Vector2, tier: EnemyStats.Tier = EnemyStats.Tier.NORMAL) -> void:
	kill_count += 1
	enemy_killed.emit(kill_count)
	gold_earned.emit(_coins)
	if equipment_system != null:
		var stage_num: int = stage_system.current_stage if stage_system != null else 1
		equipment_system.roll_loot_drop(tier, stage_num)
	if stage_system != null:
		var is_boss: bool = (tier == EnemyStats.Tier.BOSS)
		stage_system.notify_enemy_killed(is_boss)
		if stage_system.can_spawn_enemy():
			pending_respawn = true
			respawn_timer = respawn_delay
	else:
		pending_respawn = true
		respawn_timer = respawn_delay
