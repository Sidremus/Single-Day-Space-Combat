extends Node

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	if Input.is_action_just_pressed("reload_current_scene"): get_tree().reload_current_scene()

	if event.is_action_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
