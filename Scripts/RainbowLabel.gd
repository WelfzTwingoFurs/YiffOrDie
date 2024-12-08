extends Label

func _ready():
	modulate = Color( (1+randi()%10)/10.0, (1+randi()%10)/10.0, (1+randi()%10)/10.0 )

func _process(_delta):
	modulate += Color((0.0025 if randi()%2 else -0.0025),(0.0025 if randi()%2 else -0.0025),(0.0025 if randi()%2 else -0.0025))
	if   modulate.r > 1: modulate.r = 0
	elif modulate.r < 0: modulate.r = 1
	if   modulate.g > 1: modulate.g = 0
	elif modulate.g < 0: modulate.g = 1
	if   modulate.b > 1: modulate.b = 0
	elif modulate.b < 0: modulate.b = 1

