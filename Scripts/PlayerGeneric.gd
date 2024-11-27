@tool
extends CharacterBody2D
@export var player = 0
@export var frame = 0
@export var pos_hip = []
@export var pos_onehanded_reload = []
@export var pos_onehanded = []
@export var pos_tail = []

var gravity = 30
var grav_plus = 10
var grav_down = 25
var jump_speed = -1050
var max_speed = 850.0
var ground_accel = 0.04
var ground_antiaccel = 0.015 #these are for when pushing AGAINST
var ground_deaccel = 0.075 #these are for HOLDING NEUTRAL
var air_accel = 0.03
var air_antiaccel = 0.02 #these are for when pushing AGAINST
var air_deaccel = 0.035 #these are for HOLDING NEUTRAL
var animation_speed = 1.5

var input = Vector2()
var anibusy = 0 # 0=free, 1=passive animation won't replace, 2=can't interrupt, 3=can't move
var facing = 1
var gun = false
var speak = false



func _process(_delta): ############################################################# SPRITE WORK ###
	#$Sprite.frame = frame + ((spr_step*int(gun)) * (0 if ((pos_onehanded[frame].x == 0) && (pos_onehanded[frame].y == 0)) else 1))
	$Sprite.frame = (frame + (spr_step*int(speak)))
	$Sprite.scale.x = facing * spr_scale.x
	
	$Arm.frame = frame
	$Arm.scale.x = facing * spr_scale.x
	
	$Pow/Col.position.x = 17 * facing
	
	
	#speak = true if ($Voice.playing && (Time.get_ticks_msec()/100 % 3)) else false
	speak = $Voice.playing
	
	if Engine.is_editor_hint():
		$Finger.frame = frame + spr_step
		$Finger.scale.x = facing *spr_scale.x
	else:
		match gun:
			true:
				$Finger.visible = true
				$Finger.frame = frame + spr_step
				$Finger.scale.x = facing *spr_scale.x
		
		
			false:
				$Finger.visible = false
				########################################################################################
	
	
		if holding:
			if (pos_onehanded[frame].x == 0) && (pos_onehanded[frame].y == 0): holding.visible = false
			else: holding.visible = true #Checks if position exists, else don't display!!!!!!!!!!!!!
		
		queue_redraw()

func _ready():
	$Pow/Col.disabled = true
	set_handed("empty")




@export var hardtail = false
@export var idle_anim = false
@export var spr_scale = Vector2(1,1)
@export var handed_empty = preload("res://Assets/PlayerWeggy/weg_emptyhanded.png")
@export var handed_one = preload("res://Assets/PlayerWeggy/weg_onehanded.png")
@export var handed_one_reload = preload("res://Assets/PlayerWeggy/weg_onehanded_reload.png")
@export var handed_hip = preload("res://Assets/PlayerWeggy/weg_hip.png")
@export var handed_hip_pump = preload("res://Assets/PlayerWeggy/weg_hip_pump.png")
var spr_step = 20

func set_handed(string):
	match string:
		1:
			$Arm.texture = handed_one
			$Finger.texture = handed_one
		2:
			$Arm.texture = handed_one_reload
			$Finger.texture = handed_one_reload
		3:
			$Arm.texture = handed_hip
			$Finger.texture = handed_hip
		4:
			$Arm.texture = handed_hip_pump
			$Finger.texture = handed_hip_pump
		_:
			$Arm.texture = handed_empty
			$Finger.texture = handed_empty




enum STATES {WAIT,IDLE,CROUCH}
var state = STATES.IDLE

func set_state(new_state):
	state = new_state

func _physics_process(_delta):
	if !Engine.is_editor_hint():
		match state:
			STATES.WAIT:
				state_wait()
			STATES.IDLE:
				state_idle()
			STATES.CROUCH:
				state_crouch()
		################################################################################################ 
		
		move_and_slide()
		input = Vector2(Input.get_axis("moveleft"+str(player), "moveright"+str(player)), Input.get_axis("moveup"+str(player), "movedown"+str(player)))
		
		tail_logic()
		if Input.is_action_just_pressed("taunt"+str(player)): $Voice.taunt()


func _draw():
	#draw_string(ThemeDB.fallback_font, Vector2(-20, -160), str(HP), HORIZONTAL_ALIGNMENT_CENTER, -1, 40)
	draw_string(ThemeDB.fallback_font, Vector2(-20, 30), str(HP), HORIZONTAL_ALIGNMENT_CENTER, -1, 40)
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################






####################################################################################################
###         ###      ###      ###   #########
###   ###   ###   #########   ###      ###
   ###   ###      ###   ###   ###      ###

var timer = 0
func state_wait():
	$Col.position.y = -63.25
	$Col.scale.y = 1
	$Pow.position.y = -63
	$Pow/Col.scale.y = 1
	
	match is_on_floor():
		false:
			velocity.y += gravity
			velocity.x = lerp(velocity.x, 0.0, air_deaccel)
		
		true:
			velocity.x = lerp(velocity.x, 0.0, ground_deaccel)
	
	
	if HP <= 0:
		$Col.position.y = -31.625
		$Col.scale.y = 0.5
		$Grab.position.y = -31
		$Grab/Col.scale.y = 0.5
		
		match is_on_floor():
			true: $AniPlay.play("dead")
			false: if $AniPlay.current_animation != "dead": $AniPlay.play("ouchf" if ((Time.get_ticks_msec()/125) % 2 == 0) else "ouchb")
	
	else:
		timer -= 1
		if timer < 0:
			anibusy = 0
			$AniPlay.play("idle")
			set_state(STATES.IDLE)


####################################################################################################
######         ###         ###   ###         ###      ######         #########
###   ###   #########   ###   ###   ###   #########   ###      ###   ######
######      ###   ###   ###         ###   ###   ###   ############   #########

var HP = 99
var was_tag = 0#For getting hit only once by multi-shot guns, like the shotgun.
func take_damage(damage, knockback, stun, source, tag):
	was_tag = tag
	HP -= damage
	if source.knock_replace:  velocity = knockback*Vector2(sign(source.position.x-position.x), (1 if is_on_floor() else 0))
	else:                    velocity += knockback*Vector2(sign(source.position.x-position.x), (1 if is_on_floor() else 0))
	$Voice.ouch()
	
	match (sign(source.position.x-position.x)*facing):
		1.0: $AniPlay.play("ouchf")
		_:   $AniPlay.play("ouchb")
	
	
	anibusy = 3
	timer = stun
	set_state(STATES.WAIT)

func invert_facing(): facing *= -1


####################################################################################################
####################################################################################################




####################################################################################################
######   #########   #########   ###   ###   ######   ###   ###
###      ######      ###   ###   ###   ###   ###      #########
######   ###   ###   #########   #########   ######   ###   ###

func state_crouch():
	if is_on_floor() && Input.is_action_pressed("movedown"+str(player)) && !anibusy:
		$Col.position.y = -31.625
		$Col.scale.y = 0.5
		$Grab.position.y = -31
		$Grab/Col.scale.y = 0.5
		
		match bool(input.x):
			true : velocity.x = lerp(velocity.x, input.x*(max_speed/2), (ground_accel if (input.x == facing) else ground_antiaccel)/2)
			false: velocity.x = lerp(velocity.x, 0.0, ground_deaccel*2)
		
		if input.x != facing: facing_input()
		
		$AniPlay.speed_scale = abs(velocity.x/max_speed)
		$AniPlay.play("ani_sneak")
		
		
		if Input.is_action_just_pressed("jump"+str(player)): ################### JUMP ANIM ###
			anibusy = 2
			$AniPlay.speed_scale = animation_speed
			$AniPlay.play("ani_jump")
			set_state(STATES.IDLE)
		
		 
		if !holding && Input.is_action_just_pressed(("shoot")+str(player)):
			$AniPlay.speed_scale = 1
			$AniPlay.stop()
			$AniPlay.play("ani_melee")
			set_state(STATES.IDLE)
		
		
		if( grabbers.size() > 0) && !holding:
			grabber_glow()
		
		if Input.is_action_just_pressed("grab"+str(player)):
			match holding:
				false: item_grab()
				_: item_drop()
	
	
	
	
	else:
		set_state(STATES.IDLE)
####################################################################################################
####################################################################################################





####################################################################################################
###   ######      ###      #########
###   ###   ###   ###      ######
###   ######      ######   #########

func state_idle():
	$Col.position.y = -63.25
	$Col.scale.y = 1
	$Grab.position.y = -63
	$Grab/Col.scale.y = 1
	
	match is_on_floor():
		false:#!is_on_floor()
			velocity.y += gravity +(grav_plus * int(!Input.is_action_pressed("jump"+str(player)))) +(grav_down * int(Input.is_action_pressed("movedown"+str(player))))
			
			if input: ################################################################## AIR CONTROL ###
				velocity.x = lerp(velocity.x, input.x*(max_speed/(1+(1 if Input.is_action_pressed("movedown"+str(player)) else 0))), (air_accel if (input.x == facing) else air_antiaccel))
			
			else:
				velocity.x = lerp(velocity.x, 0.0, air_deaccel)
			
			
			if !holding && Input.is_action_just_pressed(("shoot")+str(player)):
				$AniPlay.speed_scale = 1
				$AniPlay.stop()
				$AniPlay.play("ani_melee")
			
			
			if $AniPlay.current_animation != "ani_melee":
				
				if $AniPlay.current_animation == "ani_jump": anibusy = 0
				
				if ($AniPlay.current_animation == "ani_run") && (!Input.is_action_pressed("jump"+str(player))) && (sign(velocity.y) >= 0):
					$AniPlay.play("ani_runoff")### AIR/RUNOFF ANIM ###
					
				if $AniPlay.current_animation != "ani_runoff" or (sign(velocity.y) < 0):
					$AniPlay.play("jump")### AIR/RUNOFF ANIM ###
					
				
			
		
		
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		
		true:#is_on_floor()
			if $AniPlay.current_animation == "jump":
				anibusy = 3
				$AniPlay.speed_scale = animation_speed
				facing_input()
				$AniPlay.play("ani_land")
			
			
			if anibusy < 1:# 0=free, 1=passive animations won't replace, 2=can't interrupt, 3=can't move
				if abs(velocity.x) > (max_speed/2.6):################################################## RUN ANIM ###
					if input.x && (facing != input.x):
						$AniPlay.play("ani_skid")
					else:
						$AniPlay.speed_scale = abs(velocity.x/max_speed)
						$AniPlay.play("ani_run")
					
				elif idle_anim: $AniPlay.play ("ani_idle")
				else: $AniPlay.play("idle" if (Time.get_ticks_msec()/1000 % (9+player)) else "blink")
				
				
				if input.x && (facing != input.x) && (abs(velocity.x) < (max_speed/2.6)):
						anibusy = 1
						$AniPlay.speed_scale = animation_speed
						$AniPlay.play("ani_turn") ######################################## TURN ANIM ###
						
				
				
			
			
			if anibusy < 2:# 0=free, 1=passive animations won't replace, 2=can't interrupt, 3=can't move
				if Input.is_action_just_pressed("jump"+str(player)): ################### JUMP ANIM ###
					anibusy = 2
					$AniPlay.speed_scale = animation_speed
					$AniPlay.play("ani_jump")
				
				##################################################################### GROUND CONTROL ###
				if input: velocity.x = lerp(velocity.x, input.x*max_speed, (ground_accel if (input.x == facing) else ground_antiaccel))
				else: velocity.x = lerp(velocity.x, 0.0, ground_deaccel)
			
			
			if anibusy < 3:
				if Input.is_action_just_pressed("grab"+str(player)):
					match holding:
						false: item_grab()
						_: item_drop()
				
				if Input.is_action_pressed("movedown"+str(player)):
					set_state(STATES.CROUCH)
				
				if !holding && Input.is_action_just_pressed(("shoot")+str(player)):
					$AniPlay.speed_scale = 1
					$AniPlay.stop()
					$AniPlay.play("ani_melee")
					anibusy = 3
			
			
			
			if anibusy == 3:
				velocity.x = lerp(velocity.x, 0.0, ground_deaccel)
	
	
	
	if( grabbers.size() > 0) && !holding:
		grabber_glow()
	
	#if Input.is_action_just_pressed("grab"+str(player)):
		#match holding:
			#false: item_grab()
			#_: item_drop()
	#
	#if Input.is_action_pressed("movedown"+str(player)):
		#set_state(STATES.CROUCH)
	


func melee_delay(): if Input.is_action_pressed("shoot"+str(player)): $AniPlay.speed_scale /= 2



######################################################################################## IDLE FUNCS

func jump(): velocity.y = jump_speed

func turn_facing():
	if (facing == input.x) && $AniPlay.current_animation == "ani_turn": $AniPlay.stop()
	elif input.x != 0: facing = input.x
	else: facing *= -1

func facing_input():
	#anibusy = 0
	if input.x != 0: facing = input.x

func set_anibusy(number): anibusy = number


var melee_damage = 10
var melee_knockback = Vector2(-500,-500)
var melee_stun = 20
var knock_replace = true
var ricochet = Vector2(-250,-250)

func _on_pow_body_entered(body):
	if body.is_in_group("player") && (body != self):
		body.take_damage(melee_damage, melee_knockback, melee_stun, self)
		velocity += ricochet * sign(body.position - position)#Vector2(sign(body.position.x - position.x), sign(body.position.y - position.y))


####################################################################################################
####################################################################################################








####################################################################################################
#########      ###      ###   ###
   ###      #########   ###   ###
   ###      ###   ###   ###   #########

func tail_logic():
	if pos_tail.size() != 0:
		$Tail.position = pos_tail[frame]*Vector2(facing,1)
		$Tail.scale.x = facing
		if is_on_floor():
			if abs(velocity.x) < 10 && ($Tail.animation == "flop1" or $Tail.animation == "flop2"): $Tail.play("wag2")
			
			
			if !hardtail:################################################## TAIL SPIN, IDLE, RUN ###
				if (abs(velocity.x) > max_speed/1.2):
					$Tail.speed_scale = 0.7 + (abs(velocity.x)+abs(velocity.y))/(max_speed/1.1)
					$Tail.play("flop1" if (Time.get_ticks_msec()/125 % 5) else "flop2")
				
				elif ($Tail.animation != "spin1") && ($Tail.animation != "spin2"):
					if !(randi() % 256):#start
						$Tail.speed_scale = 1
						$Tail.play("spin1" if ($Tail.animation == "wag1") else "spin2")
				
				elif $Tail.frame == 6:#end
					match $Tail.animation:
						"spin1": $Tail.play("wag2")
						"spin2": $Tail.play("wag1")
				
				#elif (abs(velocity.x) < 100) && ($Tail.animation == null) or ($Tail.animation == "flop2"):
				#	$Tail.play("wag1")
				
				
			else:#if hardtail:
				if (abs(velocity.x) < max_speed/1.2): $Tail.speed_scale = 1
				else: $Tail.speed_scale = 0.7 + (abs(velocity.x)+abs(velocity.y))/(max_speed/1.1)
				$Tail.play("flop1" if (abs(velocity.x) > max_speed/1.2) else "wag1")
		
		
		
		else:#!is_on_floor:
			$Tail.speed_scale = 2+ ((abs(velocity.x)+abs(velocity.y)) / (max_speed/1.1))
			
			if abs(velocity.x/2) > abs(velocity.y):
				$Tail.play("flop2" if (sign(velocity.y)+1) else "flop1")
			
			elif abs(velocity.y) > max_speed*3:
				$Tail.frame = randi () % 3
				$Tail.play("wag2" if !(Time.get_ticks_msec()/125 % int($Tail.speed_scale/2)) else "wag1")
			
			else:
				$Tail.play("wag1" if (sign(velocity.y)+1) else "wag2")
			
			
####################################################################################################
####################################################################################################




####################################################################################################
###   #########   #########      ###   ###
###      ###      ######      ###   ###   ###
###      ###      #########   ###         ### 


func _on_grab_body_exited(body):
	if grabbers.has(body) && (body.ammo_in+body.ammo_out > 0):
		body.modulate = Color(1,1,1)
		grabbers.erase(body)

func _on_grab_body_entered(body):
	if body.is_in_group("grab") && !grabbers.has(body):
		grabbers.push_back(body)

var holding = false
var grabbers = []

func grabber_glow():
	var closest = INF
	var thisone
	for item in grabbers:
		if item.ammo_in+item.ammo_out <= 0: grabbers.erase(item)
		
		item.modulate = (Color(1,1,1))
		if position.distance_to(item.position) < closest:
			closest = position.distance_to(item.position)
			thisone = item
	thisone.modulate = (Color(2,2,2)) if (Time.get_ticks_msec()/100 % 2 == 0) else (Color(1,1,1))

func item_grab():
	if grabbers.size() != 0:
		var closest = INF
		var thisone
		for item in grabbers:
			if position.distance_to(item.position) < closest:
				closest = position.distance_to(item.position)
				thisone = item
		gun = true
		thisone.holder = self
		holding = thisone

func item_drop():
	set_handed("empty")
	holding.position.x = position.x+(facing*35)
	holding.velocity = velocity*Vector2(2, (1.5 if !sign(velocity.y)+1 else 0.0))
	holding.holder = null
	holding = false
	gun = false

