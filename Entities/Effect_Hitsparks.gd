extends Sprite2D

var timer = 20

func _ready():
	frame = randi() % 2
	retimer = timer

var retimer
func _physics_process(_delta):
	retimer -= 1
	if retimer <= 1:
		queue_free()

func _process(_delta): queue_redraw()

func _draw():
	var lol = (timer/retimer)*10
	var lmao = (lol/50)+2
	
	
	if frame == 0:
		draw_circle(Vector2(lol,0)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,0)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(0,lol)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(0,-lol)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(lol,lol), lmao, Color(1,1,1))
		draw_circle(Vector2(lol,-lol), lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,lol), lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,-lol), lmao, Color(1,1,1))
		
		
	else:
		draw_circle(Vector2(lol,0), lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,0), lmao, Color(1,1,1))
		draw_circle(Vector2(0,lol), lmao, Color(1,1,1))
		draw_circle(Vector2(0,-lol), lmao, Color(1,1,1))
		draw_circle(Vector2(lol,lol)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(lol,-lol)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,lol)*2, lmao, Color(1,1,1))
		draw_circle(Vector2(-lol,-lol)*2, lmao, Color(1,1,1))
