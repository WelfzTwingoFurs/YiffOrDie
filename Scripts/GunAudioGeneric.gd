extends AudioStreamPlayer2D
@export var shoot_sfx   = load("res://Assets/gunpistol_shoot.wav")
@export var empty_sfx   = load("res://Assets/gunpistol_shoot.wav")
@export var release_sfx = load("res://Assets/gunpistol_release.wav")
@export var reload_sfx  = load("res://Assets/gunpistol_reload.wav")
@export var charge_sfx  = load("res://Assets/gunpistol_shoot.wav")

func shoot():
	set_stream(shoot_sfx)
	play()

func empty():
	set_stream(empty_sfx)
	play()

func release():
	set_stream(release_sfx)
	play()

func reload():
	set_stream(reload_sfx)
	play()

func charge():
	set_stream(charge_sfx)
	play()

#func step():
	#if !playing:#low priority
		#match (randi() % 2):
			#0: set_stream(load("res://Assets/Audio/sfx_step1.wav"))
			#1: set_stream(load("res://Assets/Audio/sfx_step2.wav"))
		#play()

#func step():
#	set_stream( (load("res://Assets/Audio/sfx_step1.wav")) if (randi() % 2) else (load("res://Assets/Audio/sfx_step2.wav")) ) 
#	play()
