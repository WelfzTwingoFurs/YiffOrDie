extends KinematicBody2D

const GRAVITY = 15
var current_speed = Vector2()
var current_acceleration = 2
var motion = Vector2()

enum STATES {FLOOR,CURRENT,POCKET}
export(int) var state = STATES.FLOOR

var inhand = 0
var face_direction = 0

var player
var inventory

export var busy = 0
######################################################################
# busy = 0 (idle) can move/jump/duck, animate, turn around, kick     #
#          (completely free)                                         #
# busy = 1 (attacking) can't do anything.                            #
#          (completely busy)                                         #
# busy = 2 (airkicking) can move/jump, turn around.                  #
#          (airkicking state)                                        #
# busy = 3 (task reason done) can move/jump, attack.                 #
#          (free but still animating)                                #
######################################################################

onready var SpriteGun = $SpriteGun
onready var SpriteArm = $SpriteArm

const lazer_projectile = preload("res://Entities/Projectiles/lazer.tscn")

var wpnname = "pistol"
const ammoMax = 250
const ammoFit = 5 # 50
var ammoOut = 5 # onready & current
var ammoIn = 5  # onready & current #25

export var spritebusy = 0

func change_state(new_state):
	state = new_state

func _ready():
	SpriteArm.visible = 0
	SpriteArm.pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	match state:
		STATES.FLOOR:
			onfloor()
		STATES.CURRENT:
			current()
		STATES.POCKET:
			pocket()

	if face_direction == 1:
		set_flipped(false)
	elif face_direction == -1:
		set_flipped(true)

func _physics_process(delta):
	if inhand == 0:
		change_state(STATES.FLOOR)
		$Shape.disabled = 0
		motion = move_and_slide(motion, Vector2(0,-1))
		motion.y += GRAVITY
		motion += current_speed # Defines speed
		if is_on_floor():
			motion.x = lerp(motion.x,0,0.20) # Friction !

		if ammoOut < 1 && ammoIn < 1:
			die()

	elif inhand == 1:
		change_state(STATES.CURRENT)
		$Shape.disabled = 1
		position.y = player.position.y
		position.x = player.position.x
		#player.Sprite.frame

	elif inhand == -1:
		change_state(STATES.POCKET)
		$Shape.disabled = 1
	
#	if ammoOut < 1 && ammoIn < 1:
#		if inhand == 0:
#			die()

func onfloor():
	player = null


func current():
	if inhand != 0:
		player.labelGun[inventory].text = str(ammoIn,"/",ammoOut)
		player.Gunbar[inventory].max_value = ammoFit
		player.Gunbar[inventory].value = ammoIn
		if face_direction == 1:
			SpriteGun.position.x = player.gunpos[0] * face_direction
		elif face_direction == -1:
			SpriteGun.position.x = player.gunpos[0] * face_direction -1
		SpriteGun.position.y = player.gunpos[1]

	if player.select == inventory:
		player.SpriteArm.texture = player.sapist
		face_direction = player.face_direction
		player.spritebusy = spritebusy
		
		if spritebusy == 1:
			player.SpriteArm.frame = SpriteArm.frame
		
		if busy == 0:
			if ammoIn > 0:
				if Input.is_action_just_pressed("ply_attack2"):
					$AnimationPlayer.stop()
					$AnimationPlayer.play("shoot")
		
		if ammoIn < 1:
			if ammoOut > 0:
				busy = 1
				$AnimationPlayer.play("reload")
		
		if Input.is_action_just_pressed("ply_wpndrop"):
				spritebusy = 0
				player.spritebusy = 0
				drop()

	else:
		SpriteGun.visible = 0
		inhand = -1
		change_state(STATES.POCKET)


func pocket():
	if player.select == inventory:
		SpriteGun.visible = 1
		inhand = 1
		change_state(STATES.CURRENT)

func set_flipped(flipstate):
	if flipstate: ### LEFT ###
		SpriteGun.flip_h = true
		SpriteArm.flip_h = true
		face_direction = -1
		if inhand == 0:
			SpriteGun.position.x = -15
			$Shape.position.x = -14
	else: ########### RIGHT ###
		SpriteGun.flip_h = false
		SpriteArm.flip_h = false
		face_direction = 1
		if inhand == 0:
			SpriteGun.position.x = 15
			$Shape.position.x = 14

func shoot_lazer():
	ammoIn -= 1
	var lazer_instance = lazer_projectile.instance()
	lazer_instance.direction = face_direction
	lazer_instance.speed = 30
	lazer_instance.position = position+Vector2(23*face_direction,player.gunpos[1]-2)
	lazer_instance.knockback = 0
	get_parent().add_child(lazer_instance)
	#$ShootSound.play()

func reload():
	if ammoOut > ammoFit:
		ammoOut = ammoOut - ammoFit
		ammoIn = ammoFit
	else:
		ammoIn = ammoOut
		ammoOut = 0
	busy = 0

func drop():
	if player.motion != null:
		motion.x = player.motion.x * 2
		if player.motion.y < 0:
			motion.y = player.motion.y * 1.5
		if player.is_on_floor() && player.motion.y > -1:
			motion.y = -100
	$AnimationPlayer.stop()
	$AnimationPlayer.play("idle")

	player.item[inventory] = null
	player.labelGun[inventory].text = ""
	player.Gunbar[inventory].value = 0
	if player.item[player.unselect] != null:
		player.select = player.unselect

	inhand = 0
	inventory = null
	change_state(STATES.FLOOR)

func die():
	if is_on_floor():
		queue_free()
