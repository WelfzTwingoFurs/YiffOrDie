extends CharacterBody2D

@export var gravity = 35
@export var die = false
@export var timer = INF

func _ready():
	if $Sprite.vframes + $Sprite.hframes > 2:
		$Sprite.frame = randi() % ($Sprite.vframes*$Sprite.hframes)
	if gravity: $Col.scale = Vector2($Sprite.texture.get_width(), $Sprite.texture.get_height())

func _physics_process(_delta):
	if gravity:
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
	
	if timer != INF:
		timer -= 1
		if timer <= 1: queue_free()
	
	
