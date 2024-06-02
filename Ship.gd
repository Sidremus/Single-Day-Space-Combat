extends CharacterBody3D
class_name Ship

var speed:float = 3.
var rot_speed:float = 2.
var acc:float = .5

var target_speed:float
var boost_fac:float = 2.3
var yaw_fac:float = .8
var yaw_to_roll_fac:float = .35
var roll_fac:float = 1.5
var current_roll:float = 0.
var mouse_rot_vec:Vector2
var current_acc_fac:float
var vel_based_rot_reduction:float
var is_drifting:bool = false
var is_boosting:bool = false
var is_braking:bool = false

@export var acc_curve:Curve
@export var rot_curve:Curve
@onready var cam: Camera3D = $CollisionShape3D/Camera3D
@onready var ui: UI = $UI

func _physics_process(delta: float) -> void:
	is_drifting = Input.is_action_pressed("drift")
	is_boosting = Input.is_action_pressed("forward")
	is_braking = Input.is_action_pressed("brake")
	target_speed = (speed if !is_boosting else speed * boost_fac) if (!is_braking && !is_drifting) else 0.
	turn_ship(delta)
	if is_braking: current_acc_fac = 2.
	else:
		current_acc_fac = clampf(global_basis.z.dot(velocity.normalized())*.5+.5,0.,1.)
		current_acc_fac = clampf(minf(current_acc_fac, velocity.length() / target_speed),0.,1.)
		current_acc_fac = acc_curve.sample(current_acc_fac)
	if !is_drifting || is_braking:
		velocity = velocity.lerp(global_basis.z * target_speed, delta * acc * current_acc_fac)
	elif is_drifting:
		velocity = velocity.slerp(velocity.limit_length(speed), delta *.05 * velocity.distance_squared_to(velocity.limit_length(speed)))
	
	move_and_slide()

func turn_ship(delta:float):
	mouse_rot_vec.x = (ui.crosshair.position + ui.crosshair.pivot_offset - ui.size*.5).x
	mouse_rot_vec.y = (ui.crosshair.position + ui.crosshair.pivot_offset - ui.size*.5).y
	mouse_rot_vec = mouse_rot_vec.limit_length(ui.center_circle_radius)/ui.center_circle_radius
	vel_based_rot_reduction = move_toward(vel_based_rot_reduction, .3 if (is_boosting && !is_drifting) else 1., delta * absf(vel_based_rot_reduction - (.3 if (is_boosting && !is_drifting) else 1.)))
	mouse_rot_vec *= vel_based_rot_reduction
	rotate(global_basis.x, rot_speed * delta * rot_curve.sample(absf(mouse_rot_vec.y)) * signf(mouse_rot_vec.y))
	rotate(global_basis.y, -rot_speed * yaw_fac * delta * rot_curve.sample(absf(mouse_rot_vec.x)) * signf(mouse_rot_vec.x))
	rotate(global_basis.z, yaw_to_roll_fac * rot_speed * yaw_fac * delta * rot_curve.sample(absf(mouse_rot_vec.x)) * signf(mouse_rot_vec.x))
	
	var target_roll:float = Input.get_axis("roll_left","roll_right")
	if target_roll == 0.:
		current_roll = move_toward(current_roll, 0., (absf(current_roll)+.15)*delta*.8)
	else:
		current_roll = move_toward(current_roll, target_roll, absf(current_roll - target_roll)*delta)
	rotate(global_basis.z, current_roll * rot_speed * roll_fac * delta)

