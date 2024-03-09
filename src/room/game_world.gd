extends Node3D

class_name GameWorld


@export var debug_displays: Array[Control] = []

@onready var bounce_animation_player: AnimationPlayer = $BouncingBall/AnimationPlayer
@onready var water_plane: MeshInstance3D = $WaterPlane
@onready var simulation: SubViewport = $Simulation
#@onready var entrance_p_cam: PhantomCamera3D = $CinematicPCam/EntrancePCam

var debug_showing: int = 0


func _ready() -> void:
	bounce_animation_player.play("bounce")
	
	# Don't know why must set in code. Godot 4 bug.
	water_plane.mesh.surface_get_material(0).set_shader_parameter('simulation_texture', simulation.get_texture())


#func start_fight() -> void:
	#entrance_p_cam.set_priority(0)
