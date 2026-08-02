class_name ArenaPlaceholder
extends Node2D

@onready var background: ArenaBackground = $Background
@onready var rings: ArenaRings = $Rings
@onready var enemy_path: EnemyPath = $EnemyPath
@onready var central_platform: CentralPlatform = $CentralPlatform
@onready var framing: ArenaFraming = $Framing
@onready var defender: DefenderPlaceholder = $DefenderPlaceholder
@onready var enemies_container: Node2D = $Enemies

const ENEMY_SCENE: PackedScene = preload("res://scenes/battle/enemy/enemy_placeholder.tscn")

func _ready() -> void:
	if defender != null:
		defender.enemies_container = enemies_container
	spawn_first_enemy()

func spawn_first_enemy() -> void:
	if enemy_path == null or enemies_container == null:
		return

	var enemy_instance: EnemyPlaceholder = ENEMY_SCENE.instantiate() as EnemyPlaceholder
	if enemy_instance != null:
		enemies_container.add_child(enemy_instance)
		var points: PackedVector2Array = enemy_path.get_points()
		enemy_instance.start_path(points)
