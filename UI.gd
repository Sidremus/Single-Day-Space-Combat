extends Control
class_name UI

var center_circle_radius:float=256.

const font = preload("res://speculum.ttf")
@onready var ship: Ship = $".."
@onready var crosshair: TextureRect = $Crosshair

func _process(_delta: float) -> void:
	crosshair.position = get_local_mouse_position() - crosshair.pivot_offset
	crosshair.modulate.a = 1. if get_local_mouse_position().distance_to(size*.5) <= center_circle_radius else .5
	queue_redraw()

func _draw() -> void:
	var ui_string:String = ""
	ui_string += "\nVEL: " + str(ship.get_real_velocity().length() * 100.).pad_decimals(0).pad_zeros(4) + " | " + str(ship.target_speed * 100.).pad_decimals(0).pad_zeros(4)
	if ship.current_fuel == ship.max_fuel:
		ui_string += "\nGAS: " + str((ship.current_fuel/ship.max_fuel)*100.).pad_decimals(1).pad_zeros(2) + "% | " + str(ship.current_fuel).pad_decimals(2).pad_zeros(3) + " / " + str(ship.max_fuel).pad_decimals(0).pad_zeros(3)
	else:
		ui_string += "\nGAS:  " + str((ship.current_fuel/ship.max_fuel)*100.).pad_decimals(1).pad_zeros(2) + "% | " + str(ship.current_fuel).pad_decimals(2).pad_zeros(3) + " / " + str(ship.max_fuel).pad_decimals(0).pad_zeros(3)
	ui_string += "\nENG:" + ("1" if !ship.is_drifting else "0") + " BST:" + ("1" if ship.is_boosting else "0")+ " BRK:" + ("1" if ship.is_braking else "0")
	
	var pos:Vector2 = Vector2(1920./4. + 200.,(1080./4.)*3. + 100.)
	var point_size:int = 24
	draw_multiline_string_outline(font, pos, ui_string,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size, -1, 8, Color.BLACK)
	draw_multiline_string(font, pos, ui_string,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,-1, Color.WHITE)
	draw_arc(size*.5, center_circle_radius,0., TAU,64, Color(Color.WHITE,.2))
	draw_arc(size*.5, center_circle_radius*ship.rot_curve.get_point_position(1).x,0., TAU,64, Color(Color.WHITE,.15))
