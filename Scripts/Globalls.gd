extends Node2D

var players = []
var respawn = false

func _process(_delta):
	if Input.is_action_pressed("bug_speedup"): Engine.time_scale += 0.05
	elif Input.is_action_pressed("bug_speeddown"): Engine.time_scale -= (0.05 if (Engine.time_scale-0.05 > 0.0) else 0.0)
	elif Input.is_action_just_released("bug_speedzero"): Engine.time_scale = 0
	elif Input.is_action_just_released("bug_speedback"): Engine.time_scale = 1
	################################################################################################
	if Input.is_action_just_pressed("bug_reset"): get_tree().reload_current_scene()
	
	if Input.is_action_just_released("bug_pause"):
		pass
