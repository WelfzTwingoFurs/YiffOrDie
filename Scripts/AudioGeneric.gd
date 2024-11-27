extends AudioStreamPlayer2D
#func step():
	#if !playing:#low priority
		#var choose = (randi() % 2)
		#if choose == 0: set_stream(load("res://Assets/Audio/sfx_step1.wav"))
		#if choose == 1: set_stream(load("res://Assets/Audio/sfx_step2.wav"))
		#play()

func step():
	if get_parent().is_on_floor():
		set_stream( (load("res://Assets/Audio/sfx_step1.wav")) if (randi() % 2) else (load("res://Assets/Audio/sfx_step2.wav")) ) 
		play()

func jump():
	set_stream(load("res://Assets/Audio/sfx_jump.wav"))
	play()

func land():
	set_stream(load("res://Assets/Audio/sfx_land.wav"))
	play()

func skid():
	set_stream(load("res://Assets/Audio/sfx_skid.wav"))
	play()

####################################################################################################

func gun_shoot():
	set_stream(load("res://Assets/Audio/gun_shoot.wav"))
	play()
