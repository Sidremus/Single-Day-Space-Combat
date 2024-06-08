extends Camera3D
class_name CamControl

var current_base_intensity:float = .0
var current_trauma:float = .0
var max_base_rot:float = 4.0
var max_trauma_rot:float = 3.0
var t1:float = -42069.
var t2:float = -42069.
@export var base_noise:Noise
@export var trauma_noise:Noise
var ref_rot:Vector3
var current_rot:Vector3

func _process(delta: float) -> void:
	t1+= delta
	t2+= delta + current_trauma * delta
	current_trauma -= maxf(current_trauma**2. * delta,delta*.5)
	current_trauma = clampf(current_trauma,0.,1.)
	
	if t1>420690.:t1=-420690.
	if t2>420690.:t2=-420690.
	
	current_rot.x = base_noise.get_noise_1d(t1) * max_base_rot * current_base_intensity
	current_rot.y = base_noise.get_noise_1d(t1+42069.) * max_base_rot * current_base_intensity
	current_rot = current_rot.limit_length(max_base_rot)
	current_rot.x += trauma_noise.get_noise_1d(t2) * max_trauma_rot * current_trauma
	current_rot.y += trauma_noise.get_noise_1d(t2+42069.) * max_trauma_rot * current_trauma
	current_rot = current_rot.limit_length(max_trauma_rot)
	rotation_degrees = ref_rot + current_rot

func _ready() -> void:
	ref_rot = rotation_degrees
