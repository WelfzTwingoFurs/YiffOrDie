extends "res://Scripts/GunGeneric.gd"



func _ready():
	start_pos = position
	projectile = preload("res://Entities/BulletGeneric.tscn")
	magazine = preload("res://Entities/Particle_Gunclip.tscn")
	guncase = preload("res://Entities/Particle_Guncase.tscn")
	
	gravity = 35
	handstate = 3
	
	ammo_in = 2
	ammo_size = 2
	ammo_out = 2
	
	name_string = "Double-Barrel"
	flash_pos = $Flash.position.x
	
	auto_refire = true

#func set_flash_pos(): flash_pos = $Flash.position.x

func eject():
	var instance = guncase.instantiate()
	instance.position = position + Vector2(0,-6)
	instance.velocity = Vector2(30*holder.facing,-30)
	get_parent().add_child(instance)

func shoot():
	if $Sprite.rotation_degrees >= 180: $Sprite.rotation_degrees = 180
	else: $Sprite.rotation_degrees = 0
	
	$Sfx.shoot()
	$Flash.flip_v = randi() % 2
	
	################################################################################################
	var instance = projectile.instantiate()
	bul_config(instance)
	
	instance.tag = create_tag()
	instance.rotation_degrees = 350 +randi()%20 #between 350-010
	
	get_parent().add_child(instance)
	################################################################################################
	################################################################################################
	################################################################################################
	instance = projectile.instantiate()#high shot
	bul_config(instance)
	
	instance.tag = instance.tag
	instance.rotation_degrees = 330 -randi()%20 #between 330-320
	
	get_parent().add_child(instance)
	################################################################################################
	################################################################################################
	################################################################################################
	instance = projectile.instantiate()#low shot
	bul_config(instance)
	
	instance.tag = instance.tag
	instance.rotation_degrees = 30 -randi()%20 #between 30-20
	
	get_parent().add_child(instance)
################################################################################################





func bul_config(fucker):
	fucker.damage = 25
	fucker.knockback = Vector2(-500,-0)
	fucker.knock_replace = true
	fucker.stun = 10
	fucker.speed = 2000.0
	fucker.dietime = 15.0
	fucker.gravity = 1.0
	fucker.deaccel = 0.0
	fucker.rotation_degrees = 340 +randi()%40
	fucker.scale = Vector2(1,1.2)
	
	
	fucker.facing = holder.facing if holder else facing
	if holder: fucker.add_collision_exception_with(holder)
	fucker.position = position + Vector2(50*(holder.facing if holder else $Sprite.scale.x),-6 * (-1 if ($Sprite.rotation_degrees >= 180) else 1))













func release():
	$Sfx.release()
	ammo_in = 0
	
	var instance = guncase.instantiate()
	instance.position = position + Vector2(0,-6)
	instance.modulate = Color(1,0,0)
	instance.velocity = Vector2( (-100+randi()%50)*holder.facing, -500 +randi()%200)
	get_parent().add_child(instance)
	var duplicate = instance.duplicate()
	duplicate.velocity = Vector2( (-100+randi()%50)*holder.facing, -500 +randi()%200)
	get_parent().add_child(duplicate)

func reload():
	$Sfx.reload()
	if ammo_out > ammo_size:
		ammo_in = ammo_size
		ammo_out -= ammo_size
	else:
		ammo_in = ammo_out
		ammo_out = 0

func set_handstate(valoo): handstate = valoo

func set_busy(yeah): busy = yeah


