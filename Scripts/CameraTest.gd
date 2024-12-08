extends Camera2D
@export var focus = -1
var players = []
func _ready(): refresh_targets()

func refresh_targets():
	players = []
	for target in get_parent().get_children():
		if target.is_in_group("player"):
			players.append(target)
	
	if focus > players.size()-1:
		focus = players.size()-1

		#if stretchy:
			#if get_viewport().size.x/(distances.x*1.5) < 1: zoom.x = get_viewport().size.x/(distances.x*1.5)
			#else: zoom.x = 1
			#if get_viewport().size.y/(distances.y*1.5) < 1: zoom.y = get_viewport().size.y/(distances.y*1.5)
			#else: zoom.y = 1

var limit = INF
var edges = Vector4(INF,INF,INF,INF)
func _process(_delta):
	refresh_targets()
	var most_left = INF
	var most_right = -INF
	var most_up = INF
	var most_down = -INF
	var here = Vector2()
	
	if focus != -1:
		position = Vector2(0,-100)+players[focus].position
		zoom = Vector2(1,1)
	
	else:
		#var camedge = Vector2(get_viewport().size.x/2, get_viewport().size.y/2)/zoom
		
		for n in players:
			if   n.position.x < edges.x-position.x:   here.x += edges.x-position.x
			elif n.position.x > edges.z-position.x:   here.x += edges.z-position.x
			else:                                     here.x += n.position.x
			
			if   n.position.y > edges.w-position.y:   here.y += edges.w-position.y
			elif n.position.y < edges.y-position.y:   here.y += edges.y-position.y
			else:                                     here.y += n.position.y
			
			
			if   n.position.x < most_left:  most_left =  n.position.x#(edges.x-position.x if (-camedge.x < edges.x-position.x) else n.position.x)
			elif n.position.x > most_right: most_right = n.position.x#(edges.x-position.x if ( camedge.x > edges.z-position.x) else n.position.x)
			if   n.position.y < most_up:    most_up =    n.position.y#(edges.x-position.y if ( camedge.y > edges.w-position.y) else n.position.y)
			elif n.position.y > most_down:  most_down =  n.position.y#(edges.x-position.y if (-camedge.y < edges.y-position.y) else n.position.y)
		
		
		position = Vector2(0,-100)+here/players.size()
		
		
		
		var distance = Vector2(most_left, most_up).distance_to(Vector2(most_right, most_down))
		if distance > limit*2: distance = limit*2
		
		
		
		
		var wow
		if get_viewport().size.x > get_viewport().size.y: 
			wow = (get_viewport().size/distance) / Vector2(float(get_viewport().size.x)/float(get_viewport().size.y), 1)
		else: 
			wow = (get_viewport().size/distance) / Vector2(1, float(get_viewport().size.y)/float(get_viewport().size.x))
		
		
		
		
		if (wow.x > 1) or (wow.y > 1) or (wow.x == 0) or (wow.y == 0): 
			zoom = Vector2(1,1)
		else: 
			zoom = wow

