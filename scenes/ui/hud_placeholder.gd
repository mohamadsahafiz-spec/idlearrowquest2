class_name HUDPlaceholder
extends Control

func _draw() -> void:
	# Top HUD Header Area Placeholder (y: 0 to 110)
	var top_bar := Rect2(0, 0, 540, 105)
	draw_rect(top_bar, Color(0.05, 0.07, 0.1, 0.85))
	draw_line(Vector2(0, 105), Vector2(540, 105), Color(0.2, 0.35, 0.5, 0.8), 2.0)
	
	# Bottom Navigation / Skill Area Placeholder (y: 750 to 960)
	var bottom_bar := Rect2(0, 750, 540, 210)
	draw_rect(bottom_bar, Color(0.05, 0.07, 0.1, 0.9))
	draw_line(Vector2(0, 750), Vector2(540, 750), Color(0.2, 0.35, 0.5, 0.8), 2.0)
