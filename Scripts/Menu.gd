extends Node

var string = "yiff, or, die?"
var menu = 3
var input = Vector2()

var ON = false
var players = 1
var rebind = 1
var gamemode = 1

func _process(_delta):
	$label.text = string
	
	if ON:
		string = "game on dudez!"
		
		if players != 1:
			var deads = 0
			for p in gamers:
				if p.HP < -200: deads += 1
				#print(p.dead)
			
			
			if deads >= players-1:
				prepare_round()
				deads = 0
		
		
		
		
		
		
		
		
		
	else:
		############################################################################################
		if $rebinder.rebinder:
			string = "REBINDING "+str(rebind)+"=\n"+$rebinder.string
			$label.text = string
			
			if Input.is_action_just_released("menu_no"):
				$rebinder.rebinder = false
				$rebinder.steps = 0
				$rebinder.player = 1
		############################################################################################
		
		
		else:#######################################################################################
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
			########################################################################################
			
			
			#########################################################################################
			if menu == 0:
				string += "[-->] "
				
				players += input.x
				if   players < 1: players = 4
				elif players > 4: players = 1
			else: string += "        "
			
			
			string += "NUMBER OF PLAYERS? <"+str(players)+">\n"
			########################################################################################
			
			########################################################################################
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
			########################################################################################
			
			########################################################################################
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
			########################################################################################
			
			########################################################################################
			if menu == 3:
				string += "[-->] "
				
				if Input.is_action_just_pressed("menu_yes"):
					prepare_round()
					ON = true
			else: string += "        "
			
			string += "START"
			########################################################################################

func prepare_round():
	
	if scenario != null: scenario.queue_free()
	scenario = scenes[randi() % scenes.size()].instantiate()
	scenario.spawnpoints.shuffle()
	add_child(scenario)
	
	
	cam = camera.instantiate()
	cam.limit = scenario.limit
	cam.edges = scenario.edges
	scenario.add_child(cam)
	
	if players != 1:
		cam.focus = -1
		
		gamers = []
		var playcount = players
		while playcount > 0:
			var playernow = player.instantiate()
			playernow.player = playcount
			playernow.position = scenario.spawnpoints[int(playcount) % scenario.spawnpoints.size()]
			playernow.position.x += playcount
			playernow.low_limit = scenario.edges.w
			gamers.push_back(playernow)
			scenario.add_child(playernow)
			playcount -= 1
	
	
	else:
		cam.focus = 1
		var playernow = player.instantiate()
		playernow.player = 1
		playernow.position = scenario.spawnpoints[players-1]
		playernow.low_limit = scenario.edges.w
		scenario.add_child(playernow)

var scenario = null
var cam = null
var gamers = []

var scenes = [preload("res://level2.tscn"), preload("res://level1.tscn")]
var player = preload("res://Entities/PlayerStud/playerStud.tscn")
var camera = preload("res://Entities/camera.tscn")
