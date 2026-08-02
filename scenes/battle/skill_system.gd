class_name SkillSystem
extends Node

signal skill_state_changed()
signal meteor_impact()

const METEOR_CD: float = 30.0
const FREEZE_CD: float = 25.0
const FREEZE_DURATION: float = 5.0
const OVERDRIVE_CD: float = 30.0
const OVERDRIVE_DURATION: float = 8.0

var meteor_cooldown: float = 0.0
var meteor_auto: bool = false

var freeze_cooldown: float = 0.0
var freeze_active_timer: float = 0.0
var freeze_auto: bool = false

var overdrive_cooldown: float = 0.0
var overdrive_active_timer: float = 0.0
var overdrive_auto: bool = false

var defender: DefenderPlaceholder = null
var enemies_container: Node2D = null
var stage_system: StageSystem = null
var progression_system: ProgressionSystem = null
var equipment_system: EquipmentSystem = null

func is_freeze_active() -> bool:
	return freeze_active_timer > 0.0

func is_overdrive_active() -> bool:
	return overdrive_active_timer > 0.0

func is_meteor_ready() -> bool:
	return meteor_cooldown <= 0.0

func is_freeze_ready() -> bool:
	return freeze_cooldown <= 0.0 and freeze_active_timer <= 0.0

func is_overdrive_ready() -> bool:
	return overdrive_cooldown <= 0.0 and overdrive_active_timer <= 0.0

func toggle_auto(skill_name: String) -> void:
	match skill_name:
		"meteor":
			meteor_auto = not meteor_auto
		"freeze":
			freeze_auto = not freeze_auto
		"overdrive":
			overdrive_auto = not overdrive_auto
	skill_state_changed.emit()

func trigger_skill(skill_name: String) -> bool:
	match skill_name:
		"meteor":
			if is_meteor_ready():
				_execute_meteor()
				meteor_cooldown = METEOR_CD
				skill_state_changed.emit()
				return true
		"freeze":
			if is_freeze_ready():
				_execute_freeze()
				freeze_cooldown = FREEZE_CD
				freeze_active_timer = FREEZE_DURATION
				skill_state_changed.emit()
				return true
		"overdrive":
			if is_overdrive_ready():
				_execute_overdrive()
				overdrive_cooldown = OVERDRIVE_CD
				overdrive_active_timer = OVERDRIVE_DURATION
				skill_state_changed.emit()
				return true
	return false

func can_auto_trigger() -> bool:
	if defender == null or not is_instance_valid(defender) or defender.current_hp <= 0.0:
		return false
	if stage_system != null:
		if stage_system.show_victory or stage_system.show_defeat or stage_system.is_transitioning:
			return false
	return true

func _process(delta: float) -> void:
	var state_changed: bool = false

	# Timers update
	if meteor_cooldown > 0.0:
		meteor_cooldown = maxf(0.0, meteor_cooldown - delta)
		state_changed = true

	if freeze_cooldown > 0.0:
		freeze_cooldown = maxf(0.0, freeze_cooldown - delta)
		state_changed = true

	if freeze_active_timer > 0.0:
		freeze_active_timer -= delta
		state_changed = true
		if freeze_active_timer <= 0.0:
			freeze_active_timer = 0.0
			_unfreeze_all_enemies()

	if overdrive_cooldown > 0.0:
		overdrive_cooldown = maxf(0.0, overdrive_cooldown - delta)
		state_changed = true

	if overdrive_active_timer > 0.0:
		overdrive_active_timer -= delta
		state_changed = true
		if overdrive_active_timer <= 0.0:
			overdrive_active_timer = 0.0
			_update_defender_speed()

	# Auto trigger logic
	if can_auto_trigger():
		if meteor_auto and is_meteor_ready() and _has_active_enemies():
			trigger_skill("meteor")
		if freeze_auto and is_freeze_ready() and _has_active_enemies():
			trigger_skill("freeze")
		if overdrive_auto and is_overdrive_ready() and _has_active_enemies():
			trigger_skill("overdrive")

	if state_changed:
		skill_state_changed.emit()

func _has_active_enemies() -> bool:
	if enemies_container == null:
		return false
	for child: Node in enemies_container.get_children():
		if child is EnemyPlaceholder:
			var enemy: EnemyPlaceholder = child as EnemyPlaceholder
			if enemy != null and is_instance_valid(enemy) and not enemy.is_dead:
				return true
	return false

func _execute_meteor() -> void:
	meteor_impact.emit()
	if defender == null or not is_instance_valid(defender) or enemies_container == null:
		return

	var meteor_mult: float = 5.0
	for child: Node in enemies_container.get_children():
		if child is EnemyPlaceholder:
			var enemy: EnemyPlaceholder = child as EnemyPlaceholder
			if enemy != null and is_instance_valid(enemy) and not enemy.is_dead:
				var hit_info: Dictionary = defender.stats.calculate_hit_damage() if defender.stats != null else {"damage": defender.damage, "is_critical": false}
				var dmg: float = float(hit_info["damage"]) * meteor_mult
				var is_crit: bool = bool(hit_info["is_critical"])
				enemy.take_damage(dmg, is_crit)

func _execute_freeze() -> void:
	if enemies_container == null:
		return
	for child: Node in enemies_container.get_children():
		if child is EnemyPlaceholder:
			var enemy: EnemyPlaceholder = child as EnemyPlaceholder
			if enemy != null and is_instance_valid(enemy) and not enemy.is_dead:
				enemy.is_frozen = true

func _unfreeze_all_enemies() -> void:
	if enemies_container == null:
		return
	for child: Node in enemies_container.get_children():
		if child is EnemyPlaceholder:
			var enemy: EnemyPlaceholder = child as EnemyPlaceholder
			if enemy != null and is_instance_valid(enemy):
				enemy.is_frozen = false

func on_enemy_spawned(enemy: EnemyPlaceholder) -> void:
	if enemy != null and is_freeze_active():
		enemy.is_frozen = true

func _execute_overdrive() -> void:
	_update_defender_speed()

func _update_defender_speed() -> void:
	if progression_system != null and defender != null:
		progression_system.apply_to_defender(defender, equipment_system, is_overdrive_active())

func reset_skills() -> void:
	meteor_cooldown = 0.0
	freeze_cooldown = 0.0
	freeze_active_timer = 0.0
	overdrive_cooldown = 0.0
	overdrive_active_timer = 0.0
	_unfreeze_all_enemies()
	_update_defender_speed()
	skill_state_changed.emit()
