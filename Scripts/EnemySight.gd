extends Node

onready var SeeEmCast = $SeeEmCast
const globalls = preload("res://Scripts/Resolution.gd")

onready var player = globalls.player
onready var enemy

onready var position = enemy

var playerXdistance = player.position.x
var playerYdistance = player.position.y

var WindowX = globalls.WindowX
var WindowY = globalls.WindowY

var Isee

func sight():
	if abs(playerXdistance) < (WindowX/4):
		if abs(playerYdistance) < (WindowY/4):
			SeeEmCast.cast_to = player.position - position

	if SeeEmCast.is_colliding():
		var body = SeeEmCast.get_collider()
		if body.is_in_group("player"):
			Isee = 1

		elif !body.is_in_group("player"):
			Isee = 0