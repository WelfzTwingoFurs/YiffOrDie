extends KinematicBody2D

const GRAVITY = 15
const JUMP_HEIGHT = -310
const MAX_SPEED = 45
export(float) var max_health = 30

var target_direction
onready var face_direction = 1

### Acceleration stuff ###
var current_speed = Vector2()
var current_acceleration = 1
var motion = Vector2()
######



### Variants ###
enum STATES {IDLE,CHASE,SWING}
export(int) var state = STATES.IDLE
onready var health = max_health

export var ouch = 0
export var busy = 0
######################################################################
### Use busy var for multiple functions, such as the old WeaponON: ###
######################################################################
# busy = 0 (idle) can move/jump, animate, turn around, attack.       #
#          (completely free)                                         #
# busy = 1 (draw/holster) can turn around.                           #
#          (draw/holster animation)                                  #
# busy = 2 (task reason done) can move/jump, attack.                 #
#          (free but still animating)                                #
# busy = 3 (attacking) can't do anything.                            #
#          (completely busy)                                         #
######################################################################
export var Isee = 0 # Currently in sight?
export var Isaw = 0 # In chase, or not? Animating in chase, or not?
export var forget = 0
######



func change_state(new_state):
	state = new_state

func _ready():
	busy = 0

### Direction change lag ###
const NOTICE = 10
var nextdir = 0
var nextdirtime = 0

func set_dir(poopoopeepee):
	if nextdir != target_direction:
		nextdir = target_direction
		nextdirtime = OS.get_ticks_msec() + NOTICE

# face_direction change code at chase()

######

### Sight system ###
onready var SeeEmCast = $SeeEmCast

onready var player = resolution.player

var playerXdistance
var playerYdistance

var WindowX
var WindowY

func _process(delta): # SIGHT SYSTEM STILL #
	WindowX = resolution.WindowX
	WindowY = resolution.WindowY
	
	target_direction = sign(player.position.x - position.x)
	
	playerXdistance = player.position.x - position.x
	playerYdistance = player.position.y - position.y
	
	if abs(playerXdistance) < (WindowX/4):
		if abs(playerYdistance) < (WindowY/2.5):
			SeeEmCast.cast_to = player.position - position

	if SeeEmCast.is_colliding():
		var body = SeeEmCast.get_collider()
		if body.is_in_group("player"):
			Isee = 1
			if is_on_floor() && Isaw == 0:
				Isaw = 2

		elif !body.is_in_group("player"):
			Isee = 0
			if is_on_floor() && Isaw == 1: ## Search begin ##
				#timer.start()
				#if timer.done_counting():
				Isaw = 3 ## Give up ##
				#else: ## Found player ##
				#timer.stop()
######
	match state:
		STATES.IDLE:
			idle()
		STATES.CHASE:
			chase()
		STATES.SWING:
			swing()
	
	if face_direction == 1:
		set_flipped(false)
	elif face_direction == -1:
		set_flipped(true)

func _physics_process(delta):
### Acceleration stuff ###
	motion = move_and_slide(motion, Vector2(0,-1))
	motion.y += GRAVITY
	motion += current_speed # Defines speed
	motion.x = lerp(motion.x,0,0.20) # Friction !

	current_speed.x = clamp(current_speed.x,-MAX_SPEED,MAX_SPEED) # Limits speed
	if target_direction != face_direction:
		current_speed.x = lerp(current_speed.x,0,0.20) # Slowdown Slow down
	current_acceleration = lerp(current_acceleration,2+abs(current_speed.x)*0.1,0.20)

# lerp = (Variant, value goal, change rate)
# clamp = (Value of, min limit, max limit)
######

func idle():
	current_speed.x = lerp(current_speed.x,0,0.15)
	if Isaw == 0:
		if is_on_floor():
			$AnimationPlayer.play("Idle")
		elif !is_on_floor():
			if  motion.y < -310:
				$AnimationPlayer.play("JumpIdle")

			if  motion.y > 1:
				$AnimationPlayer.play("JumpSwitchIdle")

			if motion.y > 145:
				$AnimationPlayer.play("JumpFallIdle")
	
	elif Isaw == 2:
		$AnimationPlayer.play("Draw")
	elif Isaw == 3:
		$AnimationPlayer.play("Holster")
	elif Isaw == 1:
		change_state(STATES.CHASE)

func chase():
	if player.position.x < position.x - 10:
		set_dir(-1)
	elif player.position.x > position.x + 10:
		set_dir(1)
	else:
		set_dir(0)
	
	if OS.get_ticks_msec() > nextdirtime && Isaw == 1:
		face_direction = nextdir
	
	if Isaw == 1:
		if ouch == 0:
			if abs(playerXdistance) < 30:
				if abs(playerYdistance) < 10:
					busy = 3
					swing()
			
			if is_on_floor() && busy != 3:
				current_speed.x += current_acceleration * face_direction
				if face_direction == 1:
					if face_direction == target_direction:
						$AnimationPlayer.play("run")
						$AnimationPlayer.playback_speed = current_acceleration/2
					else:
						$AnimationPlayer.play("Idle")
				elif face_direction == -1:
					if face_direction == target_direction:
						$AnimationPlayer.play("run")
						$AnimationPlayer.playback_speed = current_acceleration/2
					else:
						$AnimationPlayer.play("Idle")
		
			elif !is_on_floor() && busy != 3:
				if  motion.y < -310:
					$AnimationPlayer.play("Jump")

				if  motion.y > 1:
					$AnimationPlayer.play("JumpSwitch")

				if motion.y > 145:
					$AnimationPlayer.play("JumpFall")
	else:
		Isaw = 3
		change_state(STATES.IDLE)


func swing():
	if is_on_floor():
		stop_horizontal()
		$AnimationPlayer.play("swing")
	elif !is_on_floor():
		$AnimationPlayer.play("swingair")

func set_flipped(flipstate):
	if flipstate: #LEFT
		$Sprite.flip_h = true
		$SwordArea/SwordCol.position.x = -10
	else: #RIGHT
		$Sprite.flip_h = false
		$SwordArea/SwordCol.position.x = 10

func stop_horizontal():
	motion.x = 0
	current_speed.x = 0
	current_acceleration = 0
