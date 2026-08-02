class_name HUDPlaceholder
extends Control

var kill_count: int = 0

func update_kill_count(count: int) -> void:
	kill_count = count
	queue_redraw()

func _draw() -> void:
	# Top HUD Header Area Placeholder (y: 0 to 105)
	var top_bar: Rect2 = Rect2(0, 0, 540, 105)
	draw_rect(top_bar, Color(0.05, 0.07, 0.1, 0.85))
	draw_line(Vector2(0, 105), Vector2(540, 105), Color(0.2, 0.35, 0.5, 0.8), 2.0)

	# Kill Counter Display
	var font: Font = ThemeDB.fallback_font
	if font != null:
		var kill_text: String = "Kill Enemies: " + str(kill_count)
		# Drop shadow
		draw_string(font, Vector2(21, 56), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.0, 0.0, 0.0, 0.8))
		# Main HUD text
		draw_string(font, Vector2(20, 55), kill_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.9, 0.95, 1.0, 0.95))

	# Bottom Navigation / Skill Area Placeholder (y: 750 to 960)
	var bottom_bar: Rect2 = Rect2(0, 750, 540, 210)
	draw_rect(bottom_bar, Color(0.05, 0.07, 0.1, 0.9))
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)
