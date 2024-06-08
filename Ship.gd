extends CharacterBody3D
class_name Ship

var speed:float = 3.
var rot_speed:float = 2.
var acc:float = .5
var max_fuel:float = 256.
var fuel_drain_rate:float = 0.05

var current_fuel:float
var target_speed:float
var boost_fac:float = 2.3
var drift_rot_lerp:float = 0.
var yaw_fac:float = .8
var yaw_to_roll_fac:float = .35
var roll_fac:float = 1.5
var current_roll:float = 0.
var mouse_rot_vec:Vector2
var current_acc_fac:float
var vel_based_rot_reduction:float
var is_drifting:bool = true
var is_boosting:bool = false
var is_braking:bool = false

@export var acc_curve:Curve
@export var rot_curve:Curve
@onready var cam: CamControl = $CollisionShape3D/Camera3D
@onready var ui: UI = $UI

func _physics_process(delta: float) -> void:
	manage_systems(delta)
	if !Global.is_drift_toggle: is_drifting = Input.is_action_pressed("drift")
	is_boosting = Input.is_action_pressed("forward") && !Input.is_action_pressed("brake") && current_fuel >0.
	is_braking = Input.is_action_pressed("brake") && current_fuel >0.
	turn_ship(delta)
	move_ship(delta)
	move_and_slide()

func manage_systems(delta:float):
	if is_boosting && cam.current_trauma <=.5 && current_fuel >0. && cam.current_trauma <.5: cam.current_trauma += 2.2 *delta
	if Input.is_action_just_pressed("drift"):cam.current_trauma += .2 if is_drifting else .1
	if is_boosting && current_fuel >0.: cam.current_base_intensity = lerpf(cam.current_base_intensity, .5, delta * 5.)
	elif is_drifting: cam.current_base_intensity = lerpf(cam.current_base_intensity, lerpf(.1,.35,get_real_velocity().length()/(speed*boost_fac)), delta * .5)
	else: cam.current_base_intensity = lerpf(cam.current_base_intensity, .05, delta * 1.5)
	
	if !is_drifting && !is_braking:current_fuel -= delta * fuel_drain_rate * speed
	if is_boosting && !is_braking:current_fuel -= delta * fuel_drain_rate * ((speed*boost_fac)-speed)
	if is_braking:current_fuel -= delta * fuel_drain_rate * speed *.5
	current_fuel=clampf(current_fuel,0.,max_fuel)

func move_ship(delta:float):
	target_speed = (speed if !is_boosting else speed * boost_fac) if (!is_braking && !is_drifting) else 0.
	if current_fuel == 0.: target_speed = minf(target_speed, speed * .25)
	if is_braking: current_acc_fac = 2.
	else:
		current_acc_fac = clampf(global_basis.z.dot(velocity.normalized())*.5+.5,0.,1.)
		current_acc_fac = clampf(minf(current_acc_fac, velocity.length() / (target_speed if target_speed >0. else 1.)),0.,1.)
		current_acc_fac = acc_curve.sample(current_acc_fac)
	if !is_drifting || is_braking:
		velocity = velocity.lerp(global_basis.z * target_speed, delta * acc * current_acc_fac)
	elif is_drifting:
		velocity = velocity.slerp(velocity.limit_length(speed * boost_fac * .95), delta *.05 * velocity.distance_squared_to(velocity.limit_length(speed)))
		if is_boosting && current_fuel >0. && !is_braking:
			velocity = velocity.lerp(global_basis.z * speed * boost_fac, delta * acc * current_acc_fac * .1)

func turn_ship(delta:float):
	var old_mouse_rot_vec:= mouse_rot_vec
	mouse_rot_vec.x = (ui.crosshair.position + ui.crosshair.pivot_offset - ui.size*.5).x
	mouse_rot_vec.y = (ui.crosshair.position + ui.crosshair.pivot_offset - ui.size*.5).y
	mouse_rot_vec = mouse_rot_vec.limit_length(ui.center_circle_radius)/ui.center_circle_radius
	vel_based_rot_reduction = move_toward(vel_based_rot_reduction, .3 if (is_boosting && !is_drifting) else 1., delta * absf(vel_based_rot_reduction - (.3 if (is_boosting && !is_drifting) else 1.)))
	mouse_rot_vec *= vel_based_rot_reduction
	
	var old_roll:= current_roll
	var target_roll:float = Input.get_axis("roll_left","roll_right")
	if target_roll == 0.:
		current_roll = move_toward(current_roll, 0., (absf(current_roll)+.15)*delta*.8)
	else:
		current_roll = move_toward(current_roll, target_roll, absf(current_roll - target_roll)*delta)
	drift_rot_lerp = 1. if is_drifting else drift_rot_lerp-delta*.25
	drift_rot_lerp = clampf(drift_rot_lerp,0.,1.)
	
	mouse_rot_vec = mouse_rot_vec.slerp(old_mouse_rot_vec.move_toward(mouse_rot_vec, delta * old_mouse_rot_vec.distance_squared_to(mouse_rot_vec)), drift_rot_lerp)
	current_roll = lerpf(current_roll,lerpf(old_roll, current_roll, delta*10.),drift_rot_lerp)
	
	rotate(global_basis.x, rot_speed * delta * rot_curve.sample(absf(mouse_rot_vec.y)) * signf(mouse_rot_vec.y))
	rotate(global_basis.y, -rot_speed * yaw_fac * delta * rot_curve.sample(absf(mouse_rot_vec.x)) * signf(mouse_rot_vec.x))
	rotate(global_basis.z, yaw_to_roll_fac * rot_speed * yaw_fac * delta * rot_curve.sample(absf(mouse_rot_vec.x)) * signf(mouse_rot_vec.x))
	rotate(global_basis.z, current_roll * rot_speed * roll_fac * delta)

func _input(event: InputEvent) -> void:
	if Global.is_drift_toggle && event.is_action_pressed("drift"):is_drifting = !is_drifting

func _ready() -> void:
	current_fuel = max_fuel
