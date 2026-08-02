class_name Battle
extends Control

const StageSystemScript = preload("res://scenes/battle/stage_system.gd")

@onready var arena_placeholder: ArenaPlaceholder = $ArenaPlaceholder
@onready var hud_placeholder: HUDPlaceholder = $HUDPlaceholder
var stage_system: StageSystemScript = null

func _ready() -> void:
	stage_system = StageSystem.new()
	stage_system.name = "StageSystem"
	add_child(stage_system)

	if arena_placeholder != null:
		arena_placeholder.stage_system = stage_system
		if hud_placeholder != null:
			arena_placeholder.enemy_killed.connect(hud_placeholder.update_kill_count)

	if stage_system != null and hud_placeholder != null:
		stage_system.stage_updated.connect(hud_placeholder.update_stage_info)
		stage_system.banner_text_changed.connect(hud_placeholder.update_banner_text)
		hud_placeholder.update_stage_info(
			stage_system.current_stage,
			stage_system.current_wave,
			stage_system.total_waves,
			stage_system.enemies_killed_this_wave,
			stage_system.enemies_required_this_wave
		)
