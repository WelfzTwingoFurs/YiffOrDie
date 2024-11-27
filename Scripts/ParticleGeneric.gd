extends CharacterBody2D

var gravity = 35
@export var die = false

func _ready():
	#$Sprite.texture = load(sprite)
	$Col.scale = Vector2($Sprite.texture.get_width(), $Sprite.texture.get_height())

func _physics_process(_delta):
	move_and_slide()
	if !is_on_floor():
		velocity.y += gravity
		$Sprite.rotation_degrees += velocity.y/1000
		if $Sprite.rotation_degrees > 360: $Sprite.rotation_degrees = 0
	
	elif !die:
		
		velocity.x = lerp(velocity.x, 0.0, 0.25)
		if $Sprite.rotation_degrees < 180: $Sprite.rotation = 0
		else: $Sprite.rotation_degrees = 180
	
	else:
		queue_free()
