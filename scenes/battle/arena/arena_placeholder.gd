class_name ArenaPlaceholder
extends Node2D

signal enemy_killed(total_kills: int)

@export var respawn_delay: float = 1.0
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
var respawn_timer: float = 0.0
var pending_respawn: bool = false
var current_enemy: EnemyPlaceholder = null

func _ready() -> void:
	if defender != null:
		defender.enemies_container = enemies_container
		defender.projectiles_container = projectiles_container
	_apply_debug_settings()
	spawn_enemy()

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

func spawn_enemy() -> void:
	if enemy_path == null or enemies_container == null:
		return

	if current_enemy != null and is_instance_valid(current_enemy) and not current_enemy.is_dead:
		return

	var enemy_instance: EnemyPlaceholder = ENEMY_SCENE.instantiate() as EnemyPlaceholder
	if enemy_instance != null:
		enemy_instance.defender_target = defender
		enemies_container.add_child(enemy_instance)
		current_enemy = enemy_instance
		enemy_instance.enemy_died.connect(_on_enemy_died)
		var points: PackedVector2Array = enemy_path.get_points()
		enemy_instance.start_path(points)

func _on_enemy_died(_coins: int, _pos: Vector2) -> void:
	kill_count += 1
	enemy_killed.emit(kill_count)
	pending_respawn = true
	respawn_timer = respawn_delay
