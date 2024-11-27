@tool
extends Node2D

@export var on = false
func _process(delta):
	if on:
		print(position)
