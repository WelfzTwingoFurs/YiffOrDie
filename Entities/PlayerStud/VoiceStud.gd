extends AudioStreamPlayer2D

var hump1 = preload("res://Assets/PlayerStud/huh.wav")
var hump2 = preload("res://Assets/PlayerStud/hah.wav")
func hump():
	if !playing && !(randi() % 2):
		set_stream(hump1)
		play()

func jump():
	if !playing && !(randi() % 2):
		set_stream(hump2)
		play()

var ouch1 = preload("res://Assets/PlayerStud/oh.wav")
func ouch():
	set_stream(ouch1)
	play()

var die1 = preload("res://Assets/PlayerStud/die.wav")
func die():
	set_stream(die1)
	play()

var taunt1 = preload("res://Assets/PlayerStud/taunt1.wav")
var taunt2 = preload("res://Assets/PlayerStud/taunt2.wav")
func taunt():
	if !playing:#low priority
		set_stream(taunt1 if (randi() % 2) else taunt2)
		play()
