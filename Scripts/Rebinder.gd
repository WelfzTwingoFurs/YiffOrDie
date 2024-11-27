extends Node
#var actions = ["bug_rebind","moveleft", "moveright", "moveup", "movedown", "jump", "shoot", "sneak", "holster", "taunt"]
var actions = ["moveleft", "moveright", "moveup", "movedown"]

@export var rebinder = true
@export var player = 0

var steps = 0
func _input(event):
	if rebinder:
		if event is InputEventKey:
			InputMap.action_erase_events(str(actions[steps]+str(player)))
			InputMap.action_add_event(str(actions[steps])+str(player), event)
			
			if !Input.is_anything_pressed():
				steps += 1
		
		if steps >= actions.size():
			Engine.time_scale = 1
			steps = 0
			rebinder = false



func _process(_delta):
	if rebinder:
		print(actions[steps]+str(player))
		Engine.time_scale = 0
	else:
		if Input.is_action_just_pressed("bug_rebind"): rebinder = true
