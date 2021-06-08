extends Node

var WindowX
var WindowY

var step = 0
onready var resolution = 2

var player

func _process(delta):
	if step == 3:
		if Input.is_action_just_pressed("bug_resdivide"): # 1
			OS.window_size /= 2
			OS.center_window()

		if Input.is_action_just_pressed("bug_res2x"): # 2
			OS.window_size *= 2
			OS.center_window()

		if Input.is_action_just_pressed("bug_resagain"): # 3
			step = 0

	if Input.is_action_just_pressed("bug_reset"): #5
		get_tree().reload_current_scene()

	
	WindowX = OS.window_size.x
	WindowY = OS.window_size.y
	
	### Resolution process ###
	if step == 0:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, Vector2(WindowX, WindowY))
		OS.center_window()
		OS.window_size.x *= 9999

		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(WindowX, WindowY))
		OS.center_window()
		OS.window_size.y *= 9999

		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(WindowX, WindowY))
		step = 1
	elif step == 1:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(WindowX, WindowY))
		OS.window_size /= resolution
		OS.center_window()
		step = 2
	elif step == 2:
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(WindowX, WindowY))
		OS.window_size *= resolution
		OS.center_window()
		step = 3
	elif step == 3:
		pass






#	if Input.is_action_just_pressed("ui_res1"):
#		resolution = 1
#		step = 0
#	if Input.is_action_just_pressed("ui_res2"):
#		resolution = 2
#		step = 0
#	if Input.is_action_just_pressed("ui_res3"):
#		resolution = 3
#		step = 0
#	if Input.is_action_just_pressed("ui_res4"):
#		resolution = 4
#		step = 0
#	if Input.is_action_just_pressed("ui_res5"):
#		resolution = 5
#		step = 0
#	if Input.is_action_just_pressed("ui_res6"):
#		resolution = 6
#		step = 0
#	if Input.is_action_just_pressed("ui_res7"):
#		resolution = 7
#		step = 0
#	if Input.is_action_just_pressed("ui_res8"):
#		resolution = 9
#		step = 0
#	if Input.is_action_just_pressed("ui_res9"):
#		resolution = 9
#		step = 0
#	if Input.is_action_just_pressed("ui_res10"):
#		resolution = 10
#		step = 0
#	######
#
#	### Manual custom size ###
#	if Input.is_action_pressed("ui_resback"):#BACKSPACE
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, Vector2(WindowX, WindowY))
#		OS.center_window()
#		OS.window_size.x *= 9999
#
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, Vector2(WindowX, WindowY))
#		OS.center_window()
#		OS.window_size.y *= 9999
#
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(WindowX, WindowY))
#
#
#
#	if Input.is_action_just_pressed("ui_resdown"):
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(WindowX, WindowY))
#		OS.window_size /= 2
#		OS.center_window()
#
#	if Input.is_action_just_pressed("ui_resup"):
#		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(WindowX, WindowY))
#		OS.window_size *= 2
#		OS.center_window()
	######
