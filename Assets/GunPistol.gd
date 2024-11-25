extends CharacterBody2D

var projectile = load("res://Assets/BulletGeneric.tscn")
var magazine = load("res://Assets/ParticleGunclip.tscn")

var name_string = "Pistol"
var holder = null
var gravity = 35
var ammo_size = 3
var ammo_in = 3
var ammo_out = 3
var busy = false

func _physics_process(_delta):
	if holder == null:
		$Col.disabled = false
		move_and_slide()
		if !is_on_floor():
			velocity.y += gravity
			$Sprite.rotation_degrees += abs(Vector2().distance_to(velocity)/100)
			if $Sprite.rotation_degrees > 360: $Sprite.rotation_degrees = 0
		
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.25)
			if $Sprite.rotation_degrees < 180: $Sprite.rotation = 0
			else: $Sprite.rotation_degrees = 180
	
	else:
		$Col.disabled = true
		if !busy && holder.state != 0:
			if ammo_in:
				if Input.is_action_just_pressed("shoot"+str(holder.player)) or (($AniPlay.current_animation != "shoot") && Input.is_action_pressed("shoot"+str(holder.player))):
					ammo_in -= 1
					holder.facing_input()
					$AniPlay.stop()
					$AniPlay.play("shoot")
			elif ammo_out:
				if Input.is_action_pressed("shoot"+str(holder.player)):
					busy = true
					$AniPlay.play("reload")
			else:
				if Input.is_action_just_pressed("shoot"+str(holder.player)):
					$AniPlay.play("empty")




func _process(_delta):
	if holder:
		position = holder.position + (holder.pistol[holder.frame]*Vector2(holder.facing,1))
		velocity = Vector2(0,0)
		$Sprite.rotation_degrees = 0
		$Sprite.scale.x = holder.facing
		$Flash.scale.x  = holder.facing
		$Flash.position.x = flash_pos * holder.facing
	else:
		if ammo_in + ammo_out <= 0: modulate = Color(0.5, 0.5, 0.5)

var flash_pos = 0
func _ready(): flash_pos = $Flash.position.x

func set_busy(yeah): busy = yeah

func shoot():
	$Sfx.shoot()
	$Flash.flip_v = randi() % 2
	
	var instance = projectile.instantiate()
	instance.facing = holder.facing
	instance.position = position + Vector2(0,-6)
	instance.add_collision_exception_with(holder)
	get_parent().add_child(instance)

func release():
	$Sfx.release()
	ammo_in = 0
	
	var instance = magazine.instantiate()
	instance.position = position + Vector2(-12*holder.facing,0)
	instance.velocity = velocity
	get_parent().add_child(instance)

func reload():
	$Sfx.reload()
	if ammo_out > ammo_size:
		ammo_in = ammo_size
		ammo_out -= ammo_size
	else:
		ammo_in = ammo_out
		ammo_out = 0
