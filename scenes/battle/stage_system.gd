class_name StageSystem
extends Node

signal stage_updated(stage: int, wave: int, total_waves: int, kills: int, required_kills: int)
signal banner_text_changed(text: String)
signal spawn_allowed_changed(allowed: bool)

@export var current_stage: int = 1
@export var total_waves: int = 3
@export var wave_transition_duration: float = 1.8

var current_wave: int = 1
var enemies_killed_this_wave: int = 0
var enemies_required_this_wave: int = 5
var enemies_spawned_this_wave: int = 0
var stage_active: bool = true
var is_in_transition: bool = false
var banner_text: String = ""

var transition_timer: float = 0.0

func _ready() -> void:
	start_stage(current_stage)

func start_stage(stage_num: int) -> void:
	current_stage = stage_num
	current_wave = 1
	stage_active = true
	is_in_transition = false
	banner_text = ""
	_setup_wave(current_wave)

func _setup_wave(wave_num: int) -> void:
	current_wave = wave_num
	enemies_killed_this_wave = 0
	enemies_spawned_this_wave = 0
	enemies_required_this_wave = _get_wave_required_kills(current_stage, current_wave)
	is_in_transition = false
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
	if not stage_active or is_in_transition:
		return false
	return enemies_spawned_this_wave < enemies_required_this_wave

func notify_enemy_spawned() -> void:
	enemies_spawned_this_wave += 1

func notify_enemy_killed() -> void:
	if not stage_active or is_in_transition:
		return
	enemies_killed_this_wave += 1
	stage_updated.emit(current_stage, current_wave, total_waves, enemies_killed_this_wave, enemies_required_this_wave)

	if enemies_killed_this_wave >= enemies_required_this_wave:
		_on_wave_completed()

func _on_wave_completed() -> void:
	spawn_allowed_changed.emit(false)
	if current_wave < total_waves:
		is_in_transition = true
		banner_text = "WAVE COMPLETE"
		banner_text_changed.emit(banner_text)
		transition_timer = wave_transition_duration
	else:
		stage_active = false
		banner_text = "BOSS INCOMING"
		banner_text_changed.emit(banner_text)

func _process(delta: float) -> void:
	if is_in_transition:
		transition_timer -= delta
		if transition_timer <= 0.0:
			is_in_transition = false
			_setup_wave(current_wave + 1)
