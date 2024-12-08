@tool
extends Node2D

func _process(delta):
	queue_redraw()

func _draw():
	draw_string(ThemeDB.fallback_font, Vector2(0,-20), str(Vector2(int(position.x), int(position.y))) + str(get_parent().frame))
