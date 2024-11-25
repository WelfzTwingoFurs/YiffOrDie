extends CharacterBody2D

var damage = 15
var knockback = Vector2(-250,-250)
var knock_replace = true
var stun = 10
var facing = 1
var speed = 3000.0
var dietime = 20.0
var gravity = 1.0
var deaccel = 0.0


func _physics_process(_delta):
	move_and_slide()
	velocity.x = lerp(velocity.x, 0.0, deaccel)
	velocity.y -= gravity
	
	if dietime != INF:
		dietime -= 1
		if dietime <= 0: queue_free()
	
#	if is_on_floor() or is_on_wall() or is_on_ceiling(): queue_free()

func _ready():
	$Sprite.scale.x = facing
	velocity.x = speed*facing


func _on_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, knockback, stun, self)
		queue_free()
