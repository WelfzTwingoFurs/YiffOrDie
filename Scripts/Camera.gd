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
	var most_left = INF
	var most_right = -INF
	var most_up = INF
	var most_down = -INF
	
	var here = Vector2()
	if focus == -1:
		for n in players:
			here += n.position
			
			if n.position.x < most_left: most_left = n.position.x
			if n.position.x > most_right: most_right = n.position.x
			if n.position.y < most_up: most_up = n.position.y
			if n.position.y > most_down: most_down = n.position.y
			
		position = Vector2(0,-100)+here/players.size()
		
		
		var distance = Vector2(most_left, most_up).distance_to(Vector2(most_right, most_down))
		
		var wow
		if get_viewport().size.x > get_viewport().size.y:
			wow = (get_viewport().size/distance) / Vector2(float(get_viewport().size.x)/float(get_viewport().size.y), 1)
		else:
			wow = (get_viewport().size/distance) / Vector2(1, float(get_viewport().size.y)/float(get_viewport().size.x))
		
		
		
		if (wow.x > 1) or wow.y > 1:
			zoom = Vector2(1,1)
		else:
			zoom = wow
		
		
		
		
	else:
		if players[focus].player != focus:
			players[focus].player = focus
		position = Vector2(0,-100)+players[focus].position
		zoom = Vector2(1,1)
















		#if stretchy:
			#if get_viewport().size.x/(distances.x*1.5) < 1: zoom.x = get_viewport().size.x/(distances.x*1.5)
			#else: zoom.x = 1
			#if get_viewport().size.y/(distances.y*1.5) < 1: zoom.y = get_viewport().size.y/(distances.y*1.5)
			#else: zoom.y = 1
