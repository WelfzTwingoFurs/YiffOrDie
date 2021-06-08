extends KinematicBody2D

const UP = Vector2(0, -1)
var speed = 2
var knockback = 0
var knock = 0
var motion = Vector2()
var damagearr = []
var direction = 1
#onready var player = globalls.player
onready var time = $Timer


var player_projectile = false

func _ready():
	$LazerArea/LazerCol.disabled = false
	$CollisionShape2D.disabled = true
	time.start()
	$AnimationPlayer.play("idle")
	motion.x = (speed * 20) * direction

func _physics_process(delta):
	motion.y = 0
	if time.is_stopped():
		$CollisionShape2D.disabled = false
		$LazerArea/LazerCol.disabled = false

	motion = move_and_slide(motion, Vector2(0,-1))
	motion.x += speed * direction

	for body in damagearr:
		body.take_damage(20, direction)
		$LazerArea/LazerCol.disabled = true

	if time.is_stopped():
		if is_on_ceiling() or is_on_floor() or is_on_wall():
			die()

#########AAAAAAAAAAAA#########
func die():
	$LazerArea/LazerCol.disabled = true
	speed = 0
	motion.x = 0
	if direction == 1:
		$AnimationPlayer.play("dieR")
	elif direction == -1:
		$AnimationPlayer.play("dieL")
	elif direction == 0:
		$AnimationPlayer.play("die")
	else:
		$AnimationPlayer.play("die")

func _on_LazerArea_body_entered(body):
	if body.is_in_group("player"):
		var type = "red"
		body.take_damage(20, direction, type)
		$LazerArea/LazerCol.disabled = true
