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

var kill_count: int = 0
var equipment_system: EquipmentSystem = null
var skill_system: SkillSystem = null
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

func _ready() -> void:
	if defender != null:
		defender.enemies_container = enemies_container
		defender.projectiles_container = projectiles_container
		if not defender.defender_died.is_connected(_on_defender_died):
			defender.defender_died.connect(_on_defender_died)
	_apply_debug_settings()
	# Spawning will be triggered after stage_system is assigned or if null
	call_deferred("_initial_spawn")

func _on_defender_died() -> void:
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
	if defender != null:
		defender.restore_base_stats()

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
		var stage_num: int = stage_system.current_stage if stage_system != null else 1
		enemy_instance.stats = EnemyStats.create_for_tier(tier, stage_num)
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
