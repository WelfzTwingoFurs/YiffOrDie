#@tool
extends CharacterBody2D
@export var player = 1
@export var frame = 0
@export var pos_highaim = []
@export var pos_hip = []
@export var pos_reload = []
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
var speak = false

var low_limit = INF





####################################################################################################
####################################################################################################
func _process(_delta): ############################################################# SPRITE WORK ###
	queue_redraw()
	if (position.y > low_limit) && HP > 0:
		$Voice.die()
		HP = -150
		set_state(STATES.WAIT)
	
	
	$Sprite.material.set_shader_parameter("player", player)
	$Sprite.frame = (frame + (spr_step*int(speak)))
	$Sprite.scale.x = facing * spr_scale.x
	
	$Arm.frame = frame
	$Arm.scale.x = facing * spr_scale.x
	
	speak = $Voice.playing if ($AniPlay.current_animation == "ani_melee") else (true if ($Voice.playing && (Time.get_ticks_msec()/100 % 3)) else false)
	
	
	
	if Engine.is_editor_hint():
		$Finger.frame = frame + spr_step
		$Finger.scale.x = facing *spr_scale.x
	else:
		match holding:
			false:
				$Finger.visible = false
			
			_:
				$Finger.visible = true
				$Finger.frame = frame + spr_step
				$Finger.scale.x = facing *spr_scale.x
	
	
	
	#make gun invisible if frame has no position for it
	if holding: holding.visible = (false if ((pos_onehanded[frame].x == 0) && (pos_onehanded[frame].y == 0)) else true)





@export var hardtail = false
@export var idle_anim = false
@export var spr_scale = Vector2(1,1)
@export var handed_empty = preload("res://Assets/PlayerWeggy/weg_emptyhanded.png")
@export var handed_one = preload("res://Assets/PlayerWeggy/weg_onehanded.png")
@export var handed_reload = preload("res://Assets/PlayerWeggy/weg_reload.png")
@export var handed_hip = preload("res://Assets/PlayerWeggy/weg_hip.png")
@export var handed_hip_pump = preload("res://Assets/PlayerWeggy/weg_hip_pump.png")
@export var handed_highaim = preload("res://Assets/PlayerWeggy/weg_highaim.png")
var spr_step = 20

func set_handed(string):
	match string:
		1:
			$Arm.texture = handed_one
			$Finger.texture = handed_one
		2:
			$Arm.texture = handed_reload
			$Finger.texture = handed_reload
		3:
			$Arm.texture = handed_hip
			$Finger.texture = handed_hip
		4:
			$Arm.texture = handed_hip_pump
			$Finger.texture = handed_hip_pump
		5:
			$Arm.texture = handed_highaim
			$Finger.texture = handed_highaim
		_:
			$Arm.texture = handed_empty
			$Finger.texture = handed_empty








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
				$Tail.play(("flop1" if (Time.get_ticks_msec()/125 % 5) else "flop2") if (abs(velocity.x) > max_speed/1.2) else "wag2")
		
		
		
		else:#!is_on_floor:
			$Tail.speed_scale = 2+ ((abs(velocity.x)+abs(velocity.y)) / (max_speed/1.1))
			
			if abs(velocity.x/2) > abs(velocity.y):
				$Tail.play("flop2" if (sign(velocity.y)+1) else "flop1")
			
			elif !hardtail && (abs(velocity.y) > max_speed*3):
				$Tail.frame = randi () % 3
				$Tail.play("wag2" if !(Time.get_ticks_msec()/125 % int($Tail.speed_scale/2)) else "wag1")
			
			else:
				$Tail.play("wag1" if (sign(velocity.y)+1) else "wag2")
			
			
#################################################################################### SPRITE WORK ###
####################################################################################################






 

####################################################################################################
####################################################################################################
var start_pos = Vector2()
func _ready():
	reconfigure()
	set_handed("empty")
	start_pos = position

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
	if HP > 0:
		draw_string(ThemeDB.fallback_font, Vector2(-20, 30), str(HP), HORIZONTAL_ALIGNMENT_CENTER, -1, 40)
####################################################################################################
####################################################################################################












####################################################################################################
####################################################################################################
#########   ###   ###   ######      ######      ######
######      ###   ###   ###   ###   ###         ###
###         #########   ###   ###   ######   ######

func collision_regular():
	$Col.position.y = -63.25
	$Col.scale.y = 1
	$Pow.position.y = -63
	$Pow/Col.scale.y = 1

func collision_crouch():
	$Col.position.y = -31.625
	$Col.scale.y = 0.5
	$Grab.position.y = -31
	$Grab/Col.scale.y = 0.5



func reconfigure():
	set_collision_layer_value(5, false)
	set_collision_layer_value(2, true)
	collision_regular()
	
	$Pow/Col.disabled = true
	
	$Tail.z_index = 0
	$Sprite.z_index = 0
	$Arm.z_index = 0
	$Finger.z_index = 1
	
	anibusy = 0
	$AniPlay.stop()
	$AniPlay.play("idle" if !idle_anim else "ani_idle")
	
	$Tail.rotation_degrees = 0
	$Tail.rotation = 0
	set_state(STATES.IDLE)



var dead = false
func die():
	dead = true
	set_collision_layer_value(5, true)
	set_collision_layer_value(2, false)
	
	collision_crouch()
	
	$AniPlay.speed_scale = 1
	
	if ($AniPlay.current_animation != "dead") && !is_on_floor():
		$AniPlay.play("ouchb" if (sign(velocity.x) == facing) else "ouchf")
	elif (abs(velocity.x) < 1) && is_on_floor():
		$AniPlay.play("dead")
	
	if holding: item_drop()
	
#	HP = 0
	set_state(STATES.WAIT)



func respawn():
	position = start_pos
	HP = 99
	reconfigure()
	dead = false
####################################################################################################
####################################################################################################






















####################################################################################################
####################################################################################################
######         ###         ###   ###         ###      ######         #########
###   ###   #########   ###   ###   ###   #########   ###      ###   ######
######      ###   ###   ###         ###   ###   ###   ############   #########

var HP = 99
var was_tag = 0#For getting hit only once by multi-shot guns, like the shotgun.
func take_damage(damage, knockback, stun, source, _tag):
	HP -= damage
	
	if source.knock_replace:  velocity = knockback*Vector2(-source.facing, (1 if is_on_floor() else 0))
	else:                    velocity += knockback*Vector2(-source.facing, (1 if is_on_floor() else 0))
	
	
	match (sign(source.position.x-position.x)*facing):
		1.0: $AniPlay.play("ouchf")
		_:   $AniPlay.play("ouchb")
	
	if HP <= 0: $Voice.die()
	else: $Voice.ouch()
	
	anibusy = 3
	timer = stun
	set_state(STATES.WAIT)

####################################################################################################

var timer = 0
func state_wait():
	collision_regular()
	
	if !is_on_floor(): velocity.y += gravity
	velocity.x = lerp(velocity.x, 0.0, ground_deaccel if is_on_floor() else air_deaccel)
	
	
	if HP > 0:
		timer -= 1
		if timer < 0:
			anibusy = 0
			$AniPlay.play("idle" if !idle_anim else "ani_idle")
			set_state(STATES.IDLE)
	
	else:
		die()
		HP -= 1
		#if HP < -300: respawn()

######################################################################################### DAMAGE ###
####################################################################################################
















####################################################################################################
####################################################################################################
######   #########   #########   ###   ###   ######   ###   ###
###      ######      ###   ###   ###   ###   ###      #########
######   ###   ###   #########   #########   ######   ###   ###

func state_crouch():
	if is_on_floor() && Input.is_action_pressed("movedown"+str(player)) && !anibusy:
		collision_crouch()
		
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
####################################################################################################
###   ######      ###      #########
###   ###   ###   ###      ######
###   ######      ######   #########

var bhop = false
func state_idle():
	collision_regular()
	
	match is_on_floor():
		false:#!is_on_floor() NOT ON FLOON, AT AIR##################################################
			if ($AniPlay.current_animation == "ani_jump") or ($AniPlay.current_animation == "ani_rejump"):
				$Sfx.jump()
				jump()#When the jump animation doesn't jump on time, be cool and let the player still jump
			
			velocity.y += gravity +(grav_plus * int(!Input.is_action_pressed("jump"+str(player)))) +(grav_down * int(Input.is_action_pressed("movedown"+str(player))))
			#Gravity according to input
			
			if input: ############################################################## AIR CONTROL ###
				velocity.x = lerp(velocity.x, input.x*(max_speed/(1+(1 if Input.is_action_pressed("movedown"+str(player)) else 0))), (air_accel if (input.x == facing) else air_antiaccel))
			
			else: velocity.x = lerp(velocity.x, 0.0, air_deaccel)
			
			
			if !holding && Input.is_action_just_pressed(("shoot")+str(player)):#Kick!
				$AniPlay.speed_scale = 1
				if anibusy < 3: $AniPlay.stop()
				$AniPlay.play("ani_melee")
			
			
			if $AniPlay.current_animation != "ani_melee":#Animation transition fixes
				if $AniPlay.current_animation == "ani_jump": anibusy = 0
				
				if ($AniPlay.current_animation == "ani_run") && (!Input.is_action_pressed("jump"+str(player))) && (sign(velocity.y) >= 0):
					$AniPlay.play("ani_runoff")### AIR/RUNOFF ANIM 
					
				if $AniPlay.current_animation != "ani_runoff" or (sign(velocity.y) < 0):
					$AniPlay.play("jumpu" if (velocity.y < 0) else "jumpd")### AIR/RUNOFF ANIM ###
					if velocity.y == 0: facing_input()#At the peak of jump
				
			
			
			if (sign(velocity.y) == 1):#Bhopping, if button is pressed in descent, jump again when land.
				if Input.is_action_just_pressed("jump"+str(player)): bhop = true
				elif Input.is_action_just_released("jump"+str(player)): bhop = false
			else:
				bhop = false
			
			
		
		
		
		
		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		true:#is_on_floor()# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
			if ($AniPlay.current_animation == "jumpu") or ($AniPlay.current_animation == "jumpd") or ($AniPlay.current_animation == "ani_runoff"):
				if bhop:
					
					anibusy = 1
					$AniPlay.speed_scale = animation_speed/1.5
					$AniPlay.play("ani_rejump")
					#dusty()
					#$Sfx.landjump()
					#$Voice.jump()
					#jump()
				else:
					anibusy = 3
					$AniPlay.speed_scale = animation_speed
					facing_input()
					$AniPlay.play("ani_land")
			
			
			
			if anibusy < 1:# 0=free, 1=passive animations won't replace, 2=can't interrupt, 3=can't move
				if abs(velocity.x) > (max_speed/2.6):#Running, skidding animations
					if input.x && (facing != input.x):
						$AniPlay.play("ani_skid")
					else:
						$AniPlay.speed_scale = abs(velocity.x/max_speed)
						$AniPlay.play("ani_run")
				
				else:#Idle animation
					$AniPlay.play(("idle" if (Time.get_ticks_msec()/1000 % (9+player)) else "blink") if !idle_anim else "ani_idle")
				
				
				if input.x && (facing != input.x) && (abs(velocity.x) < (max_speed/2.6)):
						anibusy = 1
						$AniPlay.speed_scale = animation_speed
						$AniPlay.play("ani_turn")#Turning condition and animation
						
			
			
			
			
			if anibusy < 2:
				if Input.is_action_just_pressed("jump"+str(player)):
					$AniPlay.speed_scale = animation_speed
					$AniPlay.play("ani_jump")
					anibusy = 2#Jumping animation
				
				#Ground control
				if input: velocity.x = lerp(velocity.x, input.x*max_speed, (ground_accel if (input.x == facing) else ground_antiaccel))
				else: velocity.x = lerp(velocity.x, 0.0, ground_deaccel)
			
			
			if anibusy < 3:
				if Input.is_action_pressed("movedown"+str(player)):
					set_state(STATES.CROUCH)
				
				if !holding && Input.is_action_just_pressed(("shoot")+str(player)):
					$AniPlay.speed_scale = 1
					$AniPlay.stop()
					$AniPlay.play("ani_melee")
					anibusy = 3
			
			
			
			if anibusy == 3:
				velocity.x = lerp(velocity.x, 0.0, ground_deaccel)
	###############################################################################################
	
	
	if( grabbers.size() > 0) && !holding:
		grabber_glow()
	
	if anibusy < 3:
		if Input.is_action_just_pressed("grab"+str(player)):
			match holding:
				false: item_grab()
				_: item_drop()






######################################################################################## IDLE FUNCS
func set_anibusy(number): anibusy = number

var jumpdust = preload("res://Entities/Effect_Jumpdust.tscn")
func dusty():
	var instance = jumpdust.instantiate()
	instance.position = position-Vector2(0,31)
	get_parent().add_child(instance)


func jump():
	facing_input()
	if Input.is_action_pressed("jump"+str(player)):
		velocity.y = jump_speed
	else:
		velocity.y = jump_speed/1.3




func turn_facing():
	if (facing == input.x) && $AniPlay.current_animation == "ani_turn": $AniPlay.stop()
	elif input.x != 0: facing = input.x
	else: facing *= -1

func facing_input():
	$Pow/Col.position = Vector2(17 * facing, -22)
	if input.x != 0: facing = input.x

func invert_facing(): facing *= -1


func force_melee():
	if $AniPlay.current_animation != "ani_melee":
		anibusy = 3
		$AniPlay.speed_scale = 1
		$AniPlay.stop()
		$AniPlay.play("ani_melee")
		set_state(STATES.IDLE)

func melee_delay(): if Input.is_action_pressed("shoot"+str(player)): $AniPlay.speed_scale /= 2


var melee_damage = 15
var melee_knockback = Vector2(-1000,-500)
var melee_stun = 20
var knock_replace = true
var ricochet = Vector2(-250,-250)

var hitstar = preload("res://Entities/Effect_Hitsparks.tscn")
func _on_pow_body_entered(body):
	if body.is_in_group("player") && (body != self):
		body.take_damage(melee_damage, melee_knockback, melee_stun, self, -1)
		velocity += ricochet * sign(body.position - position)
		
		$Sfx.hit()
		var instance = hitstar.instantiate()
		instance.position = position-Vector2(-82*facing, 82)
		get_parent().add_child(instance)
####################################################################################################
####################################################################################################













####################################################################################################
####################################################################################################
###   #########   #########      ###   ###
###      ###      ######      ###   ###   ###
###      ###      #########   ###         ### 

var grabbers = []
func _on_grab_body_entered(body):
	if body.is_in_group("grab") && !grabbers.has(body):
		grabbers.push_back(body)

func _on_grab_body_exited(body):
	if grabbers.has(body) && (body.ammo_in+body.ammo_out > 0):
		body.modulate = Color(1,1,1)
		grabbers.erase(body)

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

var holding = false
func item_grab():
	if grabbers.size() != 0:
		var closest = INF
		var thisone
		for item in grabbers:
			if position.distance_to(item.position) < closest:
				closest = position.distance_to(item.position)
				thisone = item
		thisone.holder = self
		holding = thisone

func item_drop():
	set_handed("empty")
	holding.position.x = position.x+(facing*35)
	holding.velocity = velocity*Vector2(2, (1.5 if !sign(velocity.y)+1 else 0.0))
	holding.holder = null
	holding = false
####################################################################################################
####################################################################################################
