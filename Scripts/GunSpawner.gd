extends Sprite2D

@export var item = load("res://Entities/GunAutoPistol.tscn")
@export var timer = 500.0
@export var wait = false
@export var ammo_in = -1
@export var ammo_out = -1


var count = 0
var checker = null
func _physics_process(_delta):
	if count > 0:
		modulate.a = 1-(count/timer)
		modulate.b = 1 if (Time.get_ticks_msec()/(int(count)*10) % 2 == 0) else 0
		checker = null
		count -= 1
	
	elif count == 0:
		modulate.a = 0
		var loaded = item.instantiate()
		loaded.position = position
		get_parent().add_child(loaded)
		if (ammo_in != -1): loaded.ammo_in = ammo_in
		if (ammo_out != -1): loaded.ammo_out = ammo_out
		checker = loaded
		count -= 1
	
	elif checker:
		if wait && (((checker.ammo_out+checker.ammo_in) <= 0) or (checker.position.y >= 900)): count = timer
		elif !wait && (checker.holder or (checker.position.y >= 900)): count = timer
	else:
		count = timer
