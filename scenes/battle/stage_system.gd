class_name StageSystem
extends Node

signal stage_updated(stage: int, wave: int, total_waves: int, kills: int, required_kills: int)
signal banner_text_changed(text: String)
signal victory_overlay_changed(show: bool, stage_num: int)
signal defeat_overlay_changed(show: bool)
signal boss_state_changed(active: bool, boss_name: String, current_hp: float, max_hp: float)
signal spawn_allowed_changed(allowed: bool)
signal spawn_boss_requested()
signal world_completed(world_id: int)

enum State {
	WAVE_ACTIVE,
	WAVE_TRANSITION,
	BOSS_INCOMING,
	BOSS_ACTIVE,
	STAGE_VICTORY,
	DEFEAT
}

@export var current_stage: int = 1
@export var total_waves: int = 3
@export var wave_transition_duration: float = 1.8
@export var boss_incoming_duration: float = 2.0
@export var victory_duration: float = 2.8

var current_wave: int = 1
var enemies_killed_this_wave: int = 0
var enemies_required_this_wave: int = 5
var enemies_spawned_this_wave: int = 0
var state: State = State.WAVE_ACTIVE
var banner_text: String = ""
var state_timer: float = 0.0

var active_boss: EnemyPlaceholder = null
var is_world_1_completed: bool = false

func _ready() -> void:
	start_stage(current_stage)

func start_stage(stage_num: int) -> void:
	current_stage = clampi(stage_num, 1, 10)
	current_wave = 1
	banner_text = ""
	state = State.WAVE_ACTIVE
	active_boss = null
	boss_state_changed.emit(false, "", 0.0, 0.0)
	victory_overlay_changed.emit(false, current_stage)
	defeat_overlay_changed.emit(false)
	_setup_wave(current_wave)

func trigger_defeat() -> void:
	state = State.DEFEAT
	banner_text = ""
	banner_text_changed.emit(banner_text)
	spawn_allowed_changed.emit(false)
	boss_state_changed.emit(false, "", 0.0, 0.0)
	defeat_overlay_changed.emit(true)

func _setup_wave(wave_num: int) -> void:
	current_wave = wave_num
	enemies_killed_this_wave = 0
	enemies_spawned_this_wave = 0
	enemies_required_this_wave = _get_wave_required_kills(current_stage, current_wave)
	state = State.WAVE_ACTIVE
	banner_text = ""
	stage_updated.emit(current_stage, current_wave, total_waves, enemies_killed_this_wave, enemies_required_this_wave)
	banner_text_changed.emit(banner_text)
	spawn_allowed_changed.emit(true)

func _get_wave_required_kills(_stage: int, wave: int) -> int:
	match wave:
		1:
			return 5
		2:
			return 8
		3:
			return 12
		_:
			return 5 + (wave - 1) * 3

func can_spawn_enemy() -> bool:
	if state != State.WAVE_ACTIVE:
		return false
	return enemies_spawned_this_wave < enemies_required_this_wave

func notify_enemy_spawned() -> void:
	enemies_spawned_this_wave += 1

func notify_enemy_killed(is_boss: bool = false) -> void:
	if is_boss:
		if state == State.BOSS_ACTIVE:
			_on_boss_killed()
		return

	if state != State.WAVE_ACTIVE:
		return

	enemies_killed_this_wave += 1
	stage_updated.emit(current_stage, current_wave, total_waves, enemies_killed_this_wave, enemies_required_this_wave)

	if enemies_killed_this_wave >= enemies_required_this_wave:
		_on_wave_completed()

func get_boss_title() -> String:
	if active_boss != null and active_boss.stats != null and not active_boss.stats.enemy_name.is_empty():
		return active_boss.stats.enemy_name
	match current_stage:
		5: return "MINI BOSS — Goblin Captain"
		8: return "WORLD BOSS — Orc Warlord"
		10: return "FINAL BOSS — Young Crimson Dragon"
		_: return "STAGE " + str(current_stage) + " BOSS"

func register_boss(boss_node: EnemyPlaceholder) -> void:
	active_boss = boss_node
	if active_boss != null:
		if not active_boss.hp_changed.is_connected(_on_boss_hp_changed):
			active_boss.hp_changed.connect(_on_boss_hp_changed)
		var boss_title: String = get_boss_title()
		boss_state_changed.emit(true, boss_title, active_boss.current_hp, active_boss.max_hp)

func _on_boss_hp_changed(hp: float, max_hp: float) -> void:
	if state == State.BOSS_ACTIVE and active_boss != null:
		var boss_title: String = get_boss_title()
		boss_state_changed.emit(true, boss_title, hp, max_hp)

func _on_wave_completed() -> void:
	spawn_allowed_changed.emit(false)
	if current_wave < total_waves:
		state = State.WAVE_TRANSITION
		banner_text = "WAVE COMPLETE"
		banner_text_changed.emit(banner_text)
		state_timer = wave_transition_duration
	else:
		state = State.BOSS_INCOMING
		banner_text = "BOSS INCOMING"
		banner_text_changed.emit(banner_text)
		state_timer = boss_incoming_duration

func _on_boss_killed() -> void:
	active_boss = null
	boss_state_changed.emit(false, "", 0.0, 0.0)
	state = State.STAGE_VICTORY
	banner_text = "WORLD 1 CLEARED!" if current_stage >= 10 else ""
	banner_text_changed.emit(banner_text)
	victory_overlay_changed.emit(true, current_stage)
	state_timer = victory_duration
	if current_stage >= 10:
		is_world_1_completed = true
		world_completed.emit(1)

func _process(delta: float) -> void:
	match state:
		State.WAVE_TRANSITION:
			state_timer -= delta
			if state_timer <= 0.0:
				_setup_wave(current_wave + 1)
		State.BOSS_INCOMING:
			state_timer -= delta
			if state_timer <= 0.0:
				state = State.BOSS_ACTIVE
				banner_text = ""
				banner_text_changed.emit(banner_text)
				spawn_boss_requested.emit()
		State.STAGE_VICTORY:
			state_timer -= delta
			if state_timer <= 0.0:
				victory_overlay_changed.emit(false, current_stage)
				if current_stage < 10:
					start_stage(current_stage + 1)
				else:
					banner_text = "ROYAL KINGDOM CLEARED!"
					banner_text_changed.emit(banner_text)
					spawn_allowed_changed.emit(false)

