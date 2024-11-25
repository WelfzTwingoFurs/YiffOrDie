extends Camera2D
@export var focus = -1
var players = []
func _ready():
	for target in get_parent().get_children():
		if target.is_in_group("player"):
			players.append(target)
	
	if focus > players.size()-1:
		focus = players.size()-1

func _process(_delta):
	var here = Vector2()
	if focus == -1:
		for n in players:
			here += n.position
		position = Vector2(0,-100)+here/players.size()
	else:
		if players[focus].player != focus:
			players[focus].player = focus
		position = Vector2(0,-100)+players[focus].position
