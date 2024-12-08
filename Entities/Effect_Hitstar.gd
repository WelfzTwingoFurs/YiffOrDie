extends Sprite2D

var timer = 20

func _ready(): frame = randi() % 2

func _physics_process(_delta):
	timer -= 1
	if timer <= 1:
		queue_free()


