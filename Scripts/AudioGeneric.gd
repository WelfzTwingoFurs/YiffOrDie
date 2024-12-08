extends AudioStreamPlayer2D
#func step():
	#if !playing:#low priority
		#var choose = (randi() % 2)
		#if choose == 0: set_stream(load("res://Assets/Audio/sfx_step1.wav"))
		#if choose == 1: set_stream(load("res://Assets/Audio/sfx_step2.wav"))
		#play()
var step1 = preload("res://Assets/Audio/sfx_step1.wav")
var step2 = preload("res://Assets/Audio/sfx_step2.wav")
func step():
	if get_parent().is_on_floor():
		set_stream( step1 if (randi() % 2) else step2 ) 
		play()

var jump1 = preload("res://Assets/Audio/sfx_jump.wav")
func jump():
	set_stream(jump1)
	play()

var land1 = preload("res://Assets/Audio/sfx_land.wav")
func land():
	set_stream(land1)
	play()

var skid1 = preload("res://Assets/Audio/sfx_skid.wav")
func skid():
	set_stream(skid1)
	play()

var hit1 = preload("res://Assets/Audio/sfx_hit.wav")
func hit():
	set_stream(hit1)
	play()

var landjump1 = preload("res://Assets/Audio/sfx_landjump.wav")
func landjump():
	set_stream(landjump1)
	play()
