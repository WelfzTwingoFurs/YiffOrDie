@tool
extends Node2D

@export var spawnpoints = []
@export var limit = 0.0
@export var edges = Vector4(0,0,0,0)

func _process(_delta): queue_redraw()

func _draw():
	for p in spawnpoints:
		draw_circle(p, 10, Color(1,1,1))
	
	draw_line(Vector2(edges.x,edges.y), Vector2(edges.z,edges.y), Color(1,1,1), 10)
	draw_line(Vector2(edges.z,edges.y), Vector2(edges.z,edges.w), Color(1,1,1), 10)
	draw_line(Vector2(edges.z,edges.w), Vector2(edges.x,edges.w), Color(1,1,1), 10)
	draw_line(Vector2(edges.x,edges.w), Vector2(edges.x,edges.y), Color(1,1,1), 10)
