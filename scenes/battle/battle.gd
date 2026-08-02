class_name Battle
extends Control

@onready var arena_placeholder: ArenaPlaceholder = $ArenaPlaceholder
@onready var hud_placeholder: HUDPlaceholder = $HUDPlaceholder

func _ready() -> void:
	if arena_placeholder != null and hud_placeholder != null:
		arena_placeholder.enemy_killed.connect(hud_placeholder.update_kill_count)
