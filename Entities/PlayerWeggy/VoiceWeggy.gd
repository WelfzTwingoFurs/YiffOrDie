extends AudioStreamPlayer2D

var hah1 = preload("res://Assets/PlayerWeggy/voice_hah1.wav")
var hah2 = preload("res://Assets/PlayerWeggy/voice_hah2.wav")
func hah():
	if (randi() % 3):
		set_stream(hah1 if (randi() % 2) else hah2)
		play()

var ouch1 = preload("res://Assets/PlayerWeggy/voice_ow.wav")
func ouch():
	set_stream(ouch1)
	play()

var die1 = preload("res://Assets/PlayerWeggy/voice_die.wav")
func die():
	set_stream(die1)
	play()

var jump1 = preload("res://Assets/PlayerWeggy/voice_jump.wav")
func jump():
	if !playing && !(randi() % 2):
		set_stream(jump1)
		play()

var taunt1 = preload("res://Assets/PlayerWeggy/voice_nag1.wav")
var taunt2 = preload("res://Assets/PlayerWeggy/voice_nag2.wav")
func taunt():
	if !playing:#low priority
		set_stream(taunt1 if (randi() % 2) else taunt2)
		play()
