extends Label

var string = "yiff, or, die?"
var menu = 3
var input = Vector2()

var ON = false
var players = 1
var rebind = 1
var gamemode = 1

func _process(_delta):
	if ON:
		string = "game on dudez!"
		
		var deads = 0
		for p in Globalls.players:
			if p.dead: deads += 1
		
		
		if deads >= was_players-1:
			deads = 0
		
		
		
		
		
		
		
		
		
	else:
		############################################################################################
		############################################################################################
		if $rebinder.rebinder:
			string = "REBINDING "+str(rebind)+"=\n"+$rebinder.string
			text = string
			
			if Input.is_action_just_released("menu_no"):
				$rebinder.rebinder = false
				$rebinder.steps = 0
				$rebinder.player = 1
		############################################################################################
		############################################################################################
		else:
			if Input.is_action_just_pressed("menu_right"): input.x = 1
			elif Input.is_action_just_pressed("menu_left"): input.x = -1
			else: input.x = 0
			if Input.is_action_just_pressed("menu_down"): input.y = 1
			elif Input.is_action_just_pressed("menu_up"): input.y = -1
			else: input.y = 0
			
			menu += input.y
			if menu < 0: menu = 3
			if menu > 3: menu = 0
			
			string = "welcome to YIFF or Die! \n"
			
			
			############################################################################################
			if menu == 0:
				string += "[-->] "
				
				players += input.x
				if   players < 1: players = 4
				elif players > 4: players = 1
			else: string += "        "
			
			
			string += "NUMBER OF PLAYERS? <"+str(players)+">\n"
			############################################################################################
			############################################################################################
			if menu == 1:
				string += "[-->] "
				
				rebind += input.x
				if   rebind < 1: rebind = players
				elif rebind > players: rebind = 1
				
				if Input.is_action_just_released("menu_yes"):
					$rebinder.rebinder = true
					$rebinder.player = rebind
			else: string += "        "
			
			string += "REBIND CONTROLS FOR PLAYER <"+str(rebind)+">\n"
			############################################################################################
			############################################################################################
			if menu == 2:
				string += "[-->] "
				
				gamemode += input.x
				if   gamemode < 1: gamemode = 5
				elif gamemode > 5: gamemode = 1
			else: string += "        "
			
			string += "GAMEMODE "
			if gamemode == 1: string += "<not implemented yet>\n"
			elif gamemode == 2: string += "<not yet implemented>\n"
			elif gamemode == 3: string += "<yet not implemented>\n"
			elif gamemode == 4: string += "<implemented yet? not>\n"
			elif gamemode == 5: string += "<yet implemented? not>\n"
			#Deathmatch: kills are score, respawning, 1 map.#KILLER SCORES
			#Quickfire, last alive scores, then map changes.#SURVIVOR SCORES
			#Race, first to the end wins, then map changes.#FIRST PLACE SCORES
			############################################################################################
			############################################################################################
			if menu == 3:
				string += "[-->] "
				
				if Input.is_action_just_pressed("menu_yes"):
					scene = scenes[randi() % scenes.size()]
					scene.spawnpoints.shuffle()
					
					if players == 1:
						camera.focus = 1
						var playernow = player.instantiate()
						playernow.player = 1
						playernow.position = scene.spawnpoints[players-1]
						playernow.low_limit = scene.edges.w
						scene.add_child(playernow)
						
					else: 
						camera.focus = -1
						was_players = players
						while players > 0:
							var playernow = player.instantiate()
							Globalls.players.append(playernow)
							playernow.player = players
							playernow.position = scene.spawnpoints[int(players) % scene.spawnpoints.size()]
							playernow.position.x += players
							playernow.low_limit = scene.edges.w
							scene.add_child(playernow)
							players -= 1
					
					scene.add_child(camera)
					camera.limit = scene.limit
					camera.edges = scene.edges
					get_tree().root.add_child(scene)
					ON = true
					#queue_free()
			else: string += "        "
			
			
			
			
			string += "START"
			############################################################################################
			
			
			
			
			
			
			
			
			
	text = string
	modulate += Color((0.0025 if randi()%2 else -0.0025),(0.0025 if randi()%2 else -0.0025),(0.0025 if randi()%2 else -0.0025))
	if   modulate.r > 1: modulate.r = 0
	elif modulate.r < 0: modulate.r = 1
	if   modulate.g > 1: modulate.g = 0
	elif modulate.g < 0: modulate.g = 1
	if   modulate.b > 1: modulate.b = 0
	elif modulate.b < 0: modulate.b = 1
func _ready():
	modulate = Color( (1+randi()%10)/10.0, (1+randi()%10)/10.0, (1+randi()%10)/10.0 )

var was_players = 0

var scene = null
var scenes = [preload("res://level2.tscn").instantiate(), preload("res://level1.tscn").instantiate()]
var player = preload("res://Entities/PlayerStud/playerStud.tscn")
var camera = preload("res://Entities/camera.tscn").instantiate()
