extends AudioStreamPlayer2D

func hah():
	if (randi() % 3):
		set_stream(load("res://Assets/PlayerWeggy/voice_hah1.wav" if (randi() % 2) else "res://Assets/PlayerWeggy/voice_hah2.wav"))
		play()

func ouch():
	set_stream(load("res://Assets/PlayerWeggy/voice_ow.wav"))
	play()

func die():
	set_stream(load("res://Assets/PlayerWeggy/voice_die.wav"))
	play()

func jump():
	if !playing && !(randi() % 2):
		set_stream(load("res://Assets/PlayerWeggy/voice_jump.wav"))
		play()

func taunt():
	if !playing:#low priority
		set_stream(load("res://Assets/PlayerWeggy/voice_nag1.wav" if (randi() % 2) else "res://Assets/PlayerWeggy/voice_nag2.wav"))
		play()
