extends Node2D
var actions = ["moveleft", "moveright", "moveup", "movedown", "jump", "shoot", "grab", "taunt"]

@export var rebinder = true
@export var player = 0

var steps = 0
func _input(event):
	if rebinder:
		if (event is InputEvent) or (event is InputEventKey) or (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
			InputMap.action_erase_events(str(actions[steps]+str(player)))
			InputMap.action_add_event(str(actions[steps])+str(player), event)
			
			if !Input.is_anything_pressed():
				steps += 1
		
		if steps >= actions.size():
			steps = 0
			rebinder = false


var string = "cool"
func _process(_delta):
	if rebinder:
		string = (actions[steps]+str(player)+"  "+str(steps)+"/"+str(actions.size())+"  "+str(rebinder))
		#Engine.time_scale = 0
	else:
		string = (actions[steps]+str(player)+"  "+str(steps)+"  "+str(rebinder))
		if Input.is_action_just_pressed("bug_rebind"): rebinder = true
	
	queue_redraw()

func _draw():
	draw_string(ThemeDB.fallback_font, Vector2(0, 0), string, HORIZONTAL_ALIGNMENT_CENTER, -1, 40, Color(1,randi()%2,1,1))
	#it appears we need constant process in order for it to function, what the fuck.
