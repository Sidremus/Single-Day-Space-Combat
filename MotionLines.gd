extends Node3D
@onready var ship: Ship = $".."
@onready var motion_line_mesh: MeshInstance3D = $MotionLineMesh
var mat:StandardMaterial3D
@onready var animation_player: AnimationPlayer = $MotionLineMesh/AnimationPlayer

func _ready() -> void: mat = motion_line_mesh.get_active_material(0)
func _process(_delta: float) -> void:
	look_at(ship.cam.global_position-ship.velocity.normalized() * 50.)
	var speed_lerp:float = clampf(ship.get_real_velocity().length() / (ship.speed * ship.boost_fac),0.,1.)
	mat.set_albedo(Color(Color.WHITE, clampf(remap(speed_lerp, 0.1,.5,0.,1.),0.,1.)))
	animation_player.speed_scale = lerp(0.01,0.04,speed_lerp)