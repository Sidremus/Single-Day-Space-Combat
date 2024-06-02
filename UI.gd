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
	ui_string += "\nVelocity: " + str(ship.get_real_velocity().length() * 100.).pad_decimals(0).pad_zeros(4) + " | " + str(ship.target_speed * 100.).pad_decimals(0).pad_zeros(4)
	ui_string += "\nDrift:" + (" ON" if ship.is_drifting else "OFF") + " | Boost:" + (" ON" if (ship.is_boosting && !ship.is_drifting && !ship.is_braking) else "OFF")
	
	var pos:Vector2 = Vector2(1920./4. + 180.,(1080./4.)*3. + 100.)
	var point_size:int = 32
	draw_multiline_string_outline(font, pos, ui_string,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size, -1, 8, Color.BLACK)
	draw_multiline_string(font, pos, ui_string,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,-1, Color.WHITE)
	draw_arc(size*.5, center_circle_radius,0., TAU,64, Color(Color.WHITE,.2))
	draw_arc(size*.5, center_circle_radius*ship.rot_curve.get_point_position(1).x,0., TAU,64, Color(Color.WHITE,.15))
