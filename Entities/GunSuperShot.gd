extends "res://Scripts/GunGeneric.gd"

func _ready():
	projectile = preload("res://Entities/BulletGeneric.tscn")
	magazine = preload("res://Entities/Particle_Gunclip.tscn")
	guncase = preload("res://Entities/Particle_Guncase.tscn")
	
	gravity = 35
	handstate = 3
	
	ammo_in = 2
	ammo_size = 2
	ammo_out = 99
	
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
	$Sfx.shoot()
	$Flash.flip_v = randi() % 2
	
	var instance = projectile.instantiate()
	
	
	instance.damage = 25
	instance.knockback = Vector2(-500,-0)
	instance.knock_replace = false
	instance.stun = 10
	instance.facing = holder.facing
	instance.speed = 3000.0
	instance.dietime = 20.0
	instance.gravity = 1.0
	instance.deaccel = 0.0
	instance.tag = Time.get_ticks_usec()+int(name_string)+int($Flash.flip_v)+ammo_out
	
	instance.facing = holder.facing
	instance.position = position + Vector2(50*holder.facing,-6)
	instance.add_collision_exception_with(holder)
	get_parent().add_child(instance)
	
	var duplicate
	duplicate = instance.duplicate()
	if holder.facing+1: duplicate.rotation_degrees = 315
	else:               duplicate.rotation_degrees = 225
	get_parent().add_child(duplicate)
	
	duplicate = instance.duplicate()
	if holder.facing+1: duplicate.rotation_degrees = 45
	else:               duplicate.rotation_degrees = 135
	get_parent().add_child(duplicate)
	
	
	
	

func negative_angle(what):
	if what < 0:
		return(180+what)
	else:
		return(what)





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
