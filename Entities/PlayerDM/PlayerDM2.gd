extends KinematicBody2D

const GRAVITY = 15
const JUMP_HEIGHT = -350
const MAX_SPEED = 50
export(float) var max_health = 100

onready var input_direction = 0
onready var face_direction = 1

### Acceleration stuff ###
var current_speed = Vector2()
var current_acceleration = 2
var motion = Vector2()
######

### Variants ###
enum STATES {IDLE,MELEE}
export(int) var state = STATES.IDLE
onready var health = max_health


export var ouch = 0
export var kick = 1
export var land = 0
export var duck = 0
var grabbed = 0

export var busy = 0
# busy = 0 (idle) can move/jump/duck, animate, turn around, kick     #
#          (completely free)                                         #
# busy = 1 (airkicking) can move/jump, turn around.                  #
#          (airkicking state)                                        #
# busy = 2 (task reason done) can move/jump, attack.                 #
#          (free but still animating)                                #
# busy = 3 (attacking) can't do anything.                            #
#          (completely busy)                                         #

export var spritebusy = 0
# spritebusy = 0 (completely free)                                     #
#          SpriteArm = Sprite, not busy, all animations from player    #
# spritebusy = 1 (weapon)                                              #
#          Arm animating, arm animations from the weapon               #
# spritebusy = 2 (completely busy)                                     #
#          All animating, all animation from weapon                    #
# spritebusy = 3 (weird)                                               #
#          Body animating, body animations from weapon                 #


onready var select = 0
onready var unselect = 1

onready var label = [$HUD/Inventory/label0, $HUD/Inventory/label1]

onready var labelM = $HUD/Inventory/labelM
var itemM

onready var item = [null,null]

onready var gunpos = Vector2()
onready var bodSprite = 0
onready var sa = safree

var jumpforgive = 2

# Node definition #

# PlayerDMBase
const sprbod = preload("res://Assets/PlayerDM/PlayerDMbase4.png")
const safree = preload("res://Assets/PlayerDM/PlayerDMarm4.png")
const sapist = preload("res://Assets/PlayerDM/PlayerDMarmPist4.png")
const sashot = preload("res://Assets/PlayerDM/PlayerDMarmShot4.png")

# Welfz
#const sprbod = preload("res://Assets/PlayerDM/WelfzFurs/WelfzBody.png")
#const safree = preload("res://Assets/PlayerDM/WelfzFurs/WelfzArm.png")
#const sapist = preload("res://Assets/PlayerDM/WelfzFurs/WelfzPist.png")
#const sashot = preload("res://Assets/PlayerDM/WelfzFurs/WelfzShot.png")

## Jerrat
#const sprbod = preload("res://Assets/PlayerDM/JerratReek/JerratBody.png")
#const safree = preload("res://Assets/PlayerDM/JerratReek/JerratArm.png")
#const sapist = preload("res://Assets/PlayerDM/JerratReek/JerratPist.png")
#const sashot = preload("res://Assets/PlayerDM/JerratReek/JerratShot.png")

onready var Sprite = $Sprite
onready var SpriteArm = $Sprite/SpriteArm
onready var Inventory = $HUD/Inventory
onready var labelGun = [$HUD/labelGun0,$HUD/labelGun1]
onready var Gunbar = [$HUD/labelGun0/Gunbar0,$HUD/labelGun1/Gunbar1]

func change_state(new_state):
	state = new_state

func _ready():
	Sprite.texture = sprbod
	resolution.player = self
	spritebusy = 0
	busy = 0
	select = 0
	kick = 1
	SpriteArm.visible = 1
	$HUD.visible = 1
	$KickArea/KickCol.disabled = 1
	gunpos = [0,0]
	SpriteArm.texture = safree

func _process(delta): ### CONSTANT LOGICS ###
	SpriteArm.texture = sa
	match state:
		STATES.IDLE:
			idle()
		STATES.MELEE:
			melee()

#directions
	if Input.is_action_pressed("ply_moveright"):
		input_direction = 1
	elif Input.is_action_pressed("ply_moveleft"):
		input_direction = -1
	else:
		input_direction = 0

	if face_direction == 1:
		set_flipped(false)
	elif face_direction == -1:
		set_flipped(true)

#hitboxes
	if !is_on_floor() && motion.y < 0:
		$ShapeCol.shape = CapsuleShape2D.new()
		$ShapeCol.shape.radius = 5.5
		$ShapeCol.shape.height = 14.5
		$ShapeCol.position.y = 6
	elif duck != 1:
		$ShapeCol.shape = RectangleShape2D.new()
		$ShapeCol.shape.extents = Vector2(5.5,12.5)
		$ShapeCol.position.y = 6
	else:
		$ShapeCol.shape = RectangleShape2D.new()
		$ShapeCol.shape.extents = Vector2(5.5,6.5)
		$ShapeCol.position.y = 12

#actions
#	if (item1 != null & item2 != null) == 0:
	if Input.is_action_pressed("ply_grab"):
#		if grabbed == 0:
		$GrabArea/GrabCol.disabled = 0
	else:
		#grabbed = 0
		$GrabArea/GrabCol.disabled = 1

	if select == 0:
		unselect = 1
	else:
		unselect = 0

	if Input.is_action_just_pressed("ply_wpnchange"):
		if item[unselect] != null:
			select = unselect

	if Input.is_action_just_released("ply_wpndrop"):
		if item[unselect] != null:
			select = unselect

	label[0].text = str(item[0])
	label[1].text = str(item[1])
	labelM.text = str(itemM)

	var color1 = (1 if select == 0 else 0.5) if item[0] else 0.25
	var colorM = 0.5 if itemM else 0.25
	var color2 = (1 if select == 1 else 0.5) if item[1] else 0.25

	Inventory.set_modulate(Color(color1, colorM, color2))
	labelGun[0].set_modulate(Color(color1, 0, 0))
	labelGun[1].set_modulate(Color(0, 0, color2))

func _physics_process(delta): ### CONSTANT PHYSICS ###
	### Acceleration stuff ###
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	motion += current_speed # Defines speed
	motion.x = lerp(motion.x,0,0.20) # Friction !
	
	current_speed.x = clamp(current_speed.x,-MAX_SPEED,MAX_SPEED) # Limits speed
	if input_direction == 0:
		current_speed.x = lerp(current_speed.x,0,0.20) # Slowdown Slow down
	current_acceleration = lerp(current_acceleration,2+abs(current_speed.x)*0.1,0.20)
	
	# lerp = (Variant, value goal, change rate)
	# clamp = (Value of, min limit, max limit)
	######
	
	if spritebusy == 0:
		SpriteArm.frame = Sprite.frame

	bodSprite = Sprite.frame
	
	
	if SpriteArm.texture == safree:
		pass

	elif SpriteArm.texture == sapist:
		if [0, 1, 2, 3, 4, 5, 65].has(bodSprite):
			gunpos = Vector2(15,2)
		if [10, 17].has(bodSprite):
			gunpos = Vector2(15,1)
		if [11, 16].has(bodSprite):
			gunpos = Vector2(15,0)
		if [12, 15].has(bodSprite):
			gunpos = Vector2(15,1)
		if [13, 14].has(bodSprite):
			gunpos = Vector2(16,0)
		if [21, 22, 23].has(bodSprite):
			gunpos = Vector2(17,-1)
		if [24, 25, 26].has(bodSprite):
			gunpos = Vector2(16,-1)
		if [27].has(bodSprite):
			gunpos = Vector2(15,4)
		if [28].has(bodSprite):
			gunpos = Vector2(17,2)
		if [30, 35, 36, 37, 38].has(bodSprite):
			gunpos = Vector2(18,4)
		if [31, 68].has(bodSprite):
			gunpos = Vector2(17,10)
		if [32, 67].has(bodSprite):
			gunpos = Vector2(19,13)
		if [33].has(bodSprite):
			gunpos = Vector2(17,11)
		if [34].has(bodSprite):
			gunpos = Vector2(17,5)

	elif SpriteArm.texture == sashot:
		if [0, 1, 2, 3, 4, 5, 65].has(bodSprite):
			gunpos = Vector2(7,7)
		if [10, 12, 15, 17].has(bodSprite):
			gunpos = Vector2(8,6)
		if [11, 16].has(bodSprite):
			gunpos = Vector2(8,5)
		if [13, 14].has(bodSprite):
			gunpos = Vector2(7,5)
		if [21, 22, 23, 24, 25, 26].has(bodSprite):
			gunpos = Vector2(8,4)
		if [27].has(bodSprite):
			gunpos = Vector2(8,8)
		if [28].has(bodSprite):
			gunpos = Vector2(9,7)
		if [30, 35, 36, 37, 38].has(bodSprite):
			gunpos = Vector2(9,10)
		if [31, 68].has(bodSprite):
			gunpos = Vector2(6,14)
		if [32, 67].has(bodSprite):
			gunpos = Vector2(7,17)
		if [33].has(bodSprite):
			gunpos = Vector2(17,15)
		if [34].has(bodSprite):
			gunpos = Vector2(9,10)

	if Input.is_action_pressed("ply_grab"):
#		if grabbed == 0:
		$GrabArea/GrabCol.disabled = 0
#		elif grabbed == 1:
#			$GrabArea/GrabCol.disabled = 1
	else:
#		grabbed = 0
		$GrabArea/GrabCol.disabled = 1



func idle():
	### MOVEMENT, FLOOR & AIR ANIMATION, FLOOR ACTIONS ###
	if busy == 0:
		if input_direction != 0:
			face_direction = input_direction

	### ON FLOOR ###
	if is_on_floor():
		if Input.is_action_pressed("ply_moveright"):
			current_speed.x += current_acceleration
		elif Input.is_action_pressed("ply_moveleft"):
			current_speed.x -= current_acceleration
		
		if Input.is_action_pressed("ply_movedown"):
			current_speed.x /= 1.22
			land = 0
			duck = 1
		elif Input.is_action_just_released("ply_movedown"):
			if duck == 1:
				duck = 2
		else:
			if input_direction == 0:
				if duck != 2:
					duck = 0
			else:
				duck = 0

		if Input.is_action_just_pressed("ply_jump"):
			motion.y = JUMP_HEIGHT
			land = 0
			jumpforgive = 2
		
		if jumpforgive == 1:
			motion.y = JUMP_HEIGHT
			land = 0
			jumpforgive = 2
		
		if busy != 2:
			if land == 0:
				if abs(current_speed.x) == clamp(abs(current_speed.x), 0, 1):
					if duck == 0:
						$AnimationPlayer.play("idle")
					elif duck == 2:
						$AnimationPlayer.play("duckup")
						
					else: #if duck != 0 ou 2
						$AnimationPlayer.play("duck")
				elif abs(current_speed.x) < MAX_SPEED*0.75:
					if duck == 0:
						if face_direction == input_direction:
							Sprite.frame = 10
						else: # if face_direction != input_direction
							#Sprite.frame = 18 #"turnaround" #
							if input_direction == 0:
								Sprite.frame = 17
					else: #if duck != 0
						$AnimationPlayer.play("duckrun")
				else: # if faster than step speed
					$AnimationPlayer.playback_speed = abs(current_acceleration)/5
					if duck == 0:
						$AnimationPlayer.play("run")
					else: #if duck != 0
						$AnimationPlayer.play("duckrun")
			else: #if land == 1
				$AnimationPlayer.play("jumpland")
				duck = 0
	

	### ON AIR ###
	elif !is_on_floor():
		if Input.is_action_pressed("ply_moveright"):
			current_speed.x = (MAX_SPEED + current_acceleration)
		elif Input.is_action_pressed("ply_moveleft"):
			current_speed.x = -(MAX_SPEED + current_acceleration)
		
		
		if motion.y > 0:
			if jumpforgive == 0:
				if Input.is_action_pressed("ply_jump"):
					jumpforgive = 1
				else:
					jumpforgive = 0
			elif jumpforgive == 2:
				if Input.is_action_just_pressed("ply_jump"):
					jumpforgive = 0
			if Input.is_action_just_released("ply_jump"):
				jumpforgive = 0
		
		land = 1
		
		if busy == 0:
			$AnimationPlayer.playback_speed = 1
			if motion.y < 0:
				$AnimationPlayer.play("jump")
			elif motion.y > 0 && motion.y < 85:
				Sprite.frame = 23
			elif motion.y > 85 && motion.y < 150:
				Sprite.frame = 24
			elif motion.y > 150:
				$AnimationPlayer.play("jumpFall")

	### ACTION ###
	if Input.is_action_just_pressed("ply_attack"):
		land = 0
		if !is_on_floor():
			kick = 3
		else:
			if Input.is_action_pressed("ply_movedown"):
				kick = 4
		face_direction = input_direction
		change_state(STATES.MELEE)



func melee():
	if Input.is_action_just_pressed("ply_attack"):
		face_direction = input_direction
		$AnimationPlayer.stop()
		if kick == 1:
			kick = 2
		elif kick == 2:
			kick = 1
	
	if is_on_floor():
		current_speed.x = lerp(current_speed.x,0,0.15)
		if kick == 1:
			$AnimationPlayer.play("kick1")
		elif kick == 2:
			$AnimationPlayer.play("kick2")
		elif kick == 3:
			$AnimationPlayer.play("kick3")
		elif kick == 4:
			$AnimationPlayer.play("kick4")
		
		if Input.is_action_just_released("ply_jump"):
			motion.y = JUMP_HEIGHT
		
		if busy == 2:
			if Input.is_action_pressed("ply_moveright"):
				current_speed.x += current_acceleration
			elif Input.is_action_pressed("ply_moveleft"):
				current_speed.x -= current_acceleration

	elif !is_on_floor():
		if kick == 3:
			$AnimationPlayer.play("kick3")
			if Input.is_action_pressed("ply_moveright"):
				current_speed.x = MAX_SPEED + current_acceleration
			elif Input.is_action_pressed("ply_moveleft"):
				current_speed.x = -MAX_SPEED - current_acceleration
		elif kick == 1:
			$AnimationPlayer.play("kick1")
		elif kick == 2:
			$AnimationPlayer.play("kick2")
		elif kick == 4:
			$AnimationPlayer.play("kick4")



func _on_GrabArea_body_entered(body):
	if body.is_in_group("pickup"):
		if item[select] == null:
			item[select] = body.wpnname
			body.inventory = select
			body.player = self
			body.inhand = 1
			labelGun[body.inventory].text = str(body.ammoIn,"/",body.ammoOut)
			Gunbar[body.inventory].max_value = body.ammoFit
			Gunbar[body.inventory].value = body.ammoIn
		else:
			if item[unselect] == null:
				item[unselect] = body.wpnname
				body.inventory = unselect
				body.player = self
				body.inhand = -1
				body.SpriteGun.visible = 0
				labelGun[body.inventory].text = str(body.ammoIn,"/",body.ammoOut)
				Gunbar[body.inventory].max_value = body.ammoFit
				Gunbar[body.inventory].value = body.ammoIn

func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		Sprite.flip_h = true
		SpriteArm.flip_h = true
		$KickArea/KickCol.position.x = -11.5
		$GrabArea/GrabCol.position.x = -3
	else: ########### RIGHT ###
		Sprite.flip_h = false
		SpriteArm.flip_h = false
		$KickArea/KickCol.position.x = 11.5
		$GrabArea/GrabCol.position.x = 3
