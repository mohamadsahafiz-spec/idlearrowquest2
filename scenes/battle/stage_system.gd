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
signal farming_mode_changed(is_farming: bool)
signal progression_interrupted(reason: String, detail: String)

enum State {
	WAVE_ACTIVE,
	WAVE_TRANSITION,
	BOSS_INCOMING,
	BOSS_ACTIVE,
	STAGE_VICTORY,
	DEFEAT
}

@export var current_world: int = 1
@export var highest_unlocked_world: int = 1
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
var completed_worlds: Array[int] = []
var is_endless_mode: bool = false
var is_farming_mode: bool = false
var is_progression_interrupted: bool = false
var interrupt_reason: String = ""
var interrupt_detail: String = ""
var interrupt_queue: Array[Dictionary] = []
var highest_slot_acknowledged: int = 3

var is_world_1_completed: bool:
	get:
		return completed_worlds.has(1)
	set(val):
		if val and not completed_worlds.has(1):
			completed_worlds.append(1)

func get_slot_count_for_world(w_id: int) -> int:
	if w_id <= 1: return 3
	elif w_id == 2: return 4
	elif w_id == 3: return 5
	else: return 6

func reset_stage_system() -> void:
	completed_worlds.clear()
	highest_unlocked_world = 1
	is_endless_mode = false
	is_farming_mode = false
	is_progression_interrupted = false
	interrupt_reason = ""
	interrupt_detail = ""
	interrupt_queue.clear()
	highest_slot_acknowledged = 3
	start_stage(1, 1)

func _ready() -> void:
	start_stage(current_stage, current_world)

func start_stage(stage_num: int, world_id: int = -1) -> void:
	if world_id > 0:
		current_world = world_id
	if current_world > highest_unlocked_world:
		highest_unlocked_world = current_world

	var max_stg: int = WorldRegistry.get_max_stages(current_world)
	if is_endless_mode:
		current_stage = max(1, stage_num)
	else:
		current_stage = clampi(stage_num, 1, max_stg)

	current_wave = 1
	banner_text = ""
	state = State.WAVE_ACTIVE
	active_boss = null
	boss_state_changed.emit(false, "", 0.0, 0.0)
	victory_overlay_changed.emit(false, current_stage)
	defeat_overlay_changed.emit(false)

	var req_slots: int = get_slot_count_for_world(current_world)
	if req_slots > highest_slot_acknowledged:
		highest_slot_acknowledged = req_slots
		trigger_progression_interrupt("slot_unlocked", "World " + str(current_world) + " Unlocked Skill Slot " + str(req_slots) + "!")

	_setup_wave(current_wave)

func trigger_progression_interrupt(reason: String, detail: String = "") -> void:
	interrupt_queue.append({"reason": reason, "detail": detail})
	if not is_progression_interrupted:
		_show_next_interrupt()
	if reason == "defeat":
		trigger_defeat()

func _show_next_interrupt() -> void:
	if interrupt_queue.is_empty():
		is_progression_interrupted = false
		interrupt_reason = ""
		interrupt_detail = ""
		return
	var item: Dictionary = interrupt_queue[0]
	is_progression_interrupted = true
	interrupt_reason = str(item.get("reason", ""))
	interrupt_detail = str(item.get("detail", ""))
	progression_interrupted.emit(interrupt_reason, interrupt_detail)

func acknowledge_interrupt() -> void:
	var prev_reason: String = interrupt_reason
	if not interrupt_queue.is_empty():
		interrupt_queue.pop_front()
	if not interrupt_queue.is_empty():
		_show_next_interrupt()
	else:
		is_progression_interrupted = false
		interrupt_reason = ""
		interrupt_detail = ""
	if prev_reason == "defeat":
		acknowledge_defeat_and_continue_farming()

func trigger_defeat() -> void:
	state = State.DEFEAT
	banner_text = ""
	banner_text_changed.emit(banner_text)
	spawn_allowed_changed.emit(false)
	boss_state_changed.emit(false, "", 0.0, 0.0)
	defeat_overlay_changed.emit(true)

func acknowledge_defeat_and_continue_farming() -> void:
	is_progression_interrupted = false
	interrupt_reason = ""
	is_farming_mode = true
	defeat_overlay_changed.emit(false)
	farming_mode_changed.emit(true)
	start_stage(current_stage, current_world)

func challenge_progression() -> void:
	is_farming_mode = false
	is_progression_interrupted = false
	interrupt_reason = ""
	farming_mode_changed.emit(false)
	start_stage(current_stage, current_world)

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
	if current_world == 1:
		match current_stage:
			5: return "MINI BOSS — Goblin Captain"
			8: return "WORLD BOSS — Orc Warlord"
			10: return "FINAL BOSS — Young Crimson Dragon"
			_: return "STAGE " + str(current_stage) + " BOSS"
	var max_stg: int = WorldRegistry.get_max_stages(current_world)
	var world_name: String = WorldRegistry.get_world_name(current_world)
	if current_stage == max_stg:
		return "FINAL BOSS — " + world_name + " Guardian"
	elif current_stage % 10 == 0:
		return "WORLD BOSS"
	elif current_stage % 5 == 0:
		return "MINI BOSS"
	return "STAGE " + str(current_stage) + " BOSS"

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
	var max_stg: int = WorldRegistry.get_max_stages(current_world)
	if is_endless_mode:
		banner_text = "STAGE " + str(current_stage) + " CLEARED!"
	elif current_stage >= max_stg:
		banner_text = WorldRegistry.get_world_name(current_world).to_upper() + " CLEARED!"
		if not completed_worlds.has(current_world):
			completed_worlds.append(current_world)
		world_completed.emit(current_world)
	else:
		banner_text = ""
	banner_text_changed.emit(banner_text)
	victory_overlay_changed.emit(true, current_stage)
	state_timer = victory_duration

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
				if is_farming_mode:
					start_stage(current_stage, current_world)
				elif is_progression_interrupted:
					pass
				else:
					var max_stg: int = WorldRegistry.get_max_stages(current_world)
					if is_endless_mode:
						start_stage(current_stage + 1, current_world)
					elif current_stage < max_stg:
						start_stage(current_stage + 1, current_world)
					else:
						if WorldRegistry.is_last_world(current_world):
							is_endless_mode = true
							banner_text = "ENDLESS MODE UNLOCKED!"
							banner_text_changed.emit(banner_text)
							start_stage(current_stage + 1, current_world)
						else:
							var next_w: int = WorldRegistry.get_next_world_id(current_world)
							current_world = next_w
							if next_w > highest_unlocked_world:
								highest_unlocked_world = next_w
							banner_text = WorldRegistry.get_world_name(current_world) + " UNLOCKED!"
							banner_text_changed.emit(banner_text)
							start_stage(1, current_world)

